// Run against a local release export. The test intercepts only the HTML boot
// scene and seeds a fresh, isolated browser context; production has no test hook.
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const base = process.env.CAMP_TEST_URL || 'http://127.0.0.1:8943';
const output = process.env.CAMP_TEST_OUTPUT || 'build/input-audit';
fs.mkdirSync(output, { recursive:true });
const fixture = { version:1, discovered_species:['mothling'], evidence:{}, inventory:{}, lure_site:{placed_objects:['lantern']}, cryptids:[{id:'typing-test-mothling',species:'mothling',name:'',trust:80,adopted:false,variant:'classic',size:'Average',personality:'Curious',quirk:'Lamp Hugger',encounter_count:4,encounter_history:[]}], sanctuary_decorations:[],moments:[],research_progress:0 };

async function saveData(page, value) {
  return page.evaluate(async value => {
    const db = await new Promise((resolve, reject) => {
      const request = indexedDB.open('/userfs', 21);
      request.onupgradeneeded = () => request.result.createObjectStore('FILE_DATA');
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
    try {
      if (value) {
        await new Promise((resolve,reject) => {
          const transaction = db.transaction('FILE_DATA','readwrite');
          for (const folder of ['/userfs/godot','/userfs/godot/app_userdata','/userfs/godot/app_userdata/Cryptid Camp']) transaction.objectStore('FILE_DATA').put({timestamp:new Date(),mode:16895},folder);
          transaction.objectStore('FILE_DATA').put({timestamp:new Date(),mode:33206,contents:new TextEncoder().encode(JSON.stringify(value))}, '/userfs/godot/app_userdata/Cryptid Camp/cryptid_camp_save.json');
          transaction.oncomplete = resolve;
          transaction.onerror = () => reject(transaction.error);
        });
        return;
      }
      return await new Promise((resolve,reject) => {
        const request = db.transaction('FILE_DATA').objectStore('FILE_DATA').get('/userfs/godot/app_userdata/Cryptid Camp/cryptid_camp_save.json');
        request.onsuccess = () => resolve(request.result ? JSON.parse(new TextDecoder().decode(request.result.contents)) : null);
        request.onerror = () => reject(request.error);
      });
    } finally { db.close(); }
  }, value);
}

(async () => {
  const browser = await chromium.launch({headless:true, executablePath:process.env.CHROME_PATH || undefined});
  const results = [];
  try {
    for (const test of [
      {name:'desktop',width:1280,height:800,mobile:false,submit:'enter'},
      {name:'mobile',width:390,height:844,mobile:true,submit:'tap'},
      {name:'small-mobile',width:320,height:568,mobile:true,submit:'enter'}
    ]) {
      const context = await browser.newContext({viewport:{width:test.width,height:test.height},isMobile:test.mobile,hasTouch:test.mobile});
      const page = await context.newPage();
      const errors = [];
      page.on('pageerror', e => { errors.push(e.message); console.error(e.message); });
      page.on('console', m => { if(m.type()==='error') { errors.push(m.text()); console.error(m.text()); } });
      await page.goto(base);
      await page.waitForFunction(() => typeof engine !== 'undefined' && engine.rtenv?.calledRun);
      await saveData(page, fixture);
      await page.route('**/index.html', async route => {
        const response = await route.fetch();
        const html = (await response.text()).replace("engine.startGame({", "engine.startGame({ args: ['res://scenes/adoption/adopt_mothling.tscn'],");
        await route.fulfill({response,body:html});
      });
      await page.goto(base+'/index.html');
      const input = page.getByRole('textbox', {name:"Your new friend's name"});
      try { await input.waitFor(); } catch(error) {
        await page.screenshot({path:path.join(output,test.name+'-failure.png')});
        console.log('Save at failure',await saveData(page));
        throw error;
      }
      if(test.mobile) await input.tap(); else await input.click();
      assert.equal(await input.evaluate(el => document.activeElement === el), true, 'tap/click focuses native field');
      assert.equal(await input.evaluate(el => {const r=el.getBoundingClientRect();return document.elementFromPoint(r.x+r.width/2,r.y+r.height/2)===el;}),true,'no overlay intercepts input');
      const formBox = await page.locator('#cryptid-name-entry').boundingBox();
      assert(Math.abs(formBox.x+formBox.width/2-test.width/2)<2,'form stays centered in the game');
      await input.pressSequentially('Misty');
      await input.press('ArrowLeft');
      await input.press('Backspace');
      assert.equal(await input.inputValue(), 'Misy', 'caret editing works');
      await input.fill('   ');
      await input.press('Enter');
      await page.getByRole('alert').filter({hasText:'Every camp resident'}).waitFor();
      assert.equal(await input.getAttribute('aria-invalid'),'true');
      await input.fill('a'.repeat(21));
      await page.getByRole('button',{name:'Welcome Home'}).click();
      await page.getByRole('alert').filter({hasText:'1–20'}).waitFor();
      await input.fill('月光');
      await input.dispatchEvent('compositionstart');
      await input.press('Enter');
      assert.equal(await input.isVisible(), true, 'IME confirmation does not adopt');
      await input.dispatchEvent('compositionend');
      // Reduced visible height exercises the same repositioning used for keyboards.
      if(test.mobile) {
        await page.setViewportSize({width:test.width,height:320});
        await page.waitForTimeout(150);
        for(const locator of [input,page.getByRole('button',{name:'Welcome Home'})]) {
          const box = await locator.boundingBox();
          assert(box.y>=0 && box.y+box.height<=320,'field and submit remain visible at keyboard-sized height');
        }
        await page.screenshot({path:path.join(output,test.name+'-keyboard-height.png')});
        await page.setViewportSize({width:test.width,height:test.height});
      }
      const name = test.name === 'desktop' ? 'Luna 🦋' : '月光 Beans';
      await input.fill('  '+name+'  ');
      await input.press('Tab');
      assert.equal(await page.getByRole('button',{name:'Welcome Home'}).evaluate(el=>document.activeElement===el),true,'Tab reaches submit');
      await page.screenshot({path:path.join(output,test.name+'-name.png')});
      if(test.submit==='tap') await page.getByRole('button',{name:'Welcome Home'}).tap();
      else { await input.focus(); await input.press('Enter'); }
      await input.waitFor({state:'detached'});
      await page.waitForTimeout(1600);
      const saved = await saveData(page);
      assert.equal(saved.cryptids[0].name,name,'real game saves submitted name');
      assert.equal(saved.cryptids[0].adopted,true);
      assert.equal(saved.cryptids.length,1);
      assert.equal(saved.cryptids[0].id,fixture.cryptids[0].id);
      assert.equal(saved.cryptids[0].trust,80);
      await page.screenshot({path:path.join(output,test.name+'-sanctuary.png')});
      await page.unroute('**/index.html');
      await page.goto(base);
      await page.waitForFunction(() => typeof engine !== 'undefined' && engine.rtenv?.calledRun);
      assert.equal(await page.locator('#cryptid-name-entry').count(),0,'no stale input overlay after reload');
      assert.equal((await saveData(page)).cryptids[0].name,name,'name survives reload');
      assert.deepEqual(errors,[]);
      results.push({viewport:test.name,status:'PASS',savedName:name,errors});
      console.log('PASS',test.name);
      await context.close();
    }
    fs.writeFileSync(path.join(output,'results.json'),JSON.stringify(results,null,2));
  } finally { await browser.close(); }
})().catch(error => { console.error(error);process.exitCode=1; });

