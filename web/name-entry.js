// A real DOM input receives the original tap, so mobile browsers can open their
// keyboard without a delayed canvas -> engine -> hidden-input focus handoff.
globalThis.CryptidNameEntry = {
  mount(onSubmit) {
    const canvas = document.querySelector('canvas');
    const previousTabIndex = canvas?.getAttribute('tabindex');
    canvas?.setAttribute('tabindex', '-1');
    const form = document.createElement('form');
    form.id = 'cryptid-name-entry';
    form.noValidate = true;
    form.setAttribute('aria-label', 'Name your Mothling');
    form.innerHTML = `
      <style>
        #cryptid-name-entry { position:fixed; z-index:10; box-sizing:border-box;
          margin:0; padding:12px; border-radius:12px; background:#131f17;
          color:#f3e5bc; font:16px/1.4 system-ui,sans-serif; overflow:auto;
          overscroll-behavior:contain; touch-action:auto; }
        #cryptid-name-entry * { box-sizing:border-box; }
        #cryptid-name-entry label { display:block; margin-bottom:6px; }
        #cryptid-name-entry input { display:block; width:100%; min-height:48px;
          font:18px/1.4 system-ui,sans-serif; padding:10px 12px; border-radius:8px;
          border:2px solid #83976b; background:#f3f0e4; color:#183326; }
        #cryptid-name-entry input:focus-visible, #cryptid-name-entry button:focus-visible {
          outline:3px solid #edce8d; outline-offset:2px; }
        #cryptid-name-entry p { font-size:13px; margin:8px 0; }
        #cryptid-name-entry button { width:100%; min-height:48px; border:1px solid #83976b;
          border-radius:10px; background:#39583e; color:#f3e5bc; font:600 16px system-ui,sans-serif;
          padding:10px; cursor:pointer; touch-action:manipulation; }
        #cryptid-name-entry [role=alert]:empty { display:none; }
        #cryptid-name-entry [role=alert] { color:#ffd998; }
      </style>
      <label for="cryptid-name">Your new friend's name</label>
      <input id="cryptid-name" name="name" type="text" autocomplete="off"
        autocapitalize="words" spellcheck="false" enterkeyhint="done"
        aria-describedby="cryptid-name-hint cryptid-name-error" placeholder="Give your friend a name…">
      <p id="cryptid-name-hint">1–20 characters. Need an idea? Beans has a nice ring to it.</p>
      <button type="submit">Welcome Home</button>
      <p id="cryptid-name-error" role="alert"></p>`;
    document.body.append(form);
    const input = form.querySelector('input');
    const button = form.querySelector('button');
    const message = form.querySelector('[role=alert]');
    let composing = false;
    let compositionEnter = false;
    let pending = false;
    let destroyed = false;
    let bounds = [0.06, 0.6, 0.88, 9 / 16];
    const viewport = window.visualViewport;
    function position(x = bounds[0], y = bounds[1], width = bounds[2], aspect = bounds[3]) {
      bounds = [x, y, width, aspect];
      const rect = canvas?.getBoundingClientRect() ?? { left:0, top:0, width:innerWidth, height:innerHeight };
      // Godot keeps a portrait viewport inside a full-window canvas. Exclude
      // its letterbox bars when mapping the engine field to CSS coordinates.
      const gameWidth = Math.min(rect.width, rect.height * aspect);
      const gameHeight = gameWidth / aspect;
      const gameLeft = rect.left + (rect.width - gameWidth) / 2;
      const gameTop = rect.top + (rect.height - gameHeight) / 2;
      const left = viewport?.offsetLeft ?? 0;
      const top = viewport?.offsetTop ?? 0;
      const visibleWidth = viewport?.width ?? innerWidth;
      const visibleHeight = viewport?.height ?? innerHeight;
      const formWidth = Math.min(Math.max(gameWidth * width, 280), visibleWidth - 16, 560);
      form.style.width = `${formWidth}px`;
      form.style.maxHeight = `${Math.max(48, visibleHeight - 16)}px`;
      form.style.left = `${Math.max(left + 8, Math.min(gameLeft + gameWidth / 2 - formWidth / 2, left + visibleWidth - formWidth - 8))}px`;
      form.style.top = `${Math.max(top + 8, Math.min(gameTop + gameHeight * y - 12, top + visibleHeight - form.offsetHeight - 8))}px`;
    }
    function error(text) {
      pending = false;
      button.disabled = false;
      message.textContent = text;
      input.setAttribute('aria-invalid', 'true');
      position();
      input.focus({ preventScroll:true });
    }
    // Keep engine keyboard listeners from also processing text or Enter. Do not
    // prevent normal editing, selection, paste, Tab, or the browser's focus action.
    for (const type of ['keydown', 'keyup', 'keypress']) {
      form.addEventListener(type, event => {
        event.stopPropagation();
        if (type === 'keydown' && event.key === 'Enter' && (event.isComposing || composing || event.keyCode === 229)) {
          // Let the IME accept its candidate; suppress only form submission.
          compositionEnter = true;
        }
        if (type === 'keyup') compositionEnter = false;
      });
    }
    input.addEventListener('compositionstart', () => { composing = true; });
    input.addEventListener('compositionend', () => { composing = false; });
    input.addEventListener('input', () => {
      message.textContent = '';
      input.removeAttribute('aria-invalid');
      position();
    });
    form.addEventListener('submit', event => {
      event.preventDefault();
      if (composing || compositionEnter || pending || destroyed) return;
      const value = input.value.trim();
      if (!value) return error('Every camp resident needs a name.');
      // Count Unicode code points like Godot, not UTF-16 units (emoji use two).
      if ([...value].length > 20) return error('Choose a name of 1–20 characters.');
      pending = true;
      button.disabled = true;
      onSubmit(value);
    });
    const reposition = () => position();
    viewport?.addEventListener('resize', reposition);
    viewport?.addEventListener('scroll', reposition);
    window.addEventListener('resize', reposition);
    position();
    // Mobile keyboard activation remains a direct tap on the visible input.
    if (matchMedia('(pointer:fine)').matches) input.focus({ preventScroll:true });
    return {
      position, error,
      destroy() {
        if (destroyed) return;
        destroyed = true;
        const ownedFocus = form.contains(document.activeElement);
        viewport?.removeEventListener('resize', reposition);
        viewport?.removeEventListener('scroll', reposition);
        window.removeEventListener('resize', reposition);
        form.remove();
        if (canvas) {
          if (previousTabIndex === null) canvas.removeAttribute('tabindex');
          else canvas.setAttribute('tabindex', previousTabIndex);
          if (ownedFocus) canvas.focus({ preventScroll:true });
        }
      }
    };
  }
};
