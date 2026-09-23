/**
 * Theater Fill for YouTube — content script.
 *
 * Keeps the `ytf-on` class on <html> in sync with the extension's enabled
 * state. The class gates every rule in content.css, so toggling it switches
 * the fill behavior instantly, live, with no page reload. State is persisted
 * in storage.local and shared across tabs via storage.onChanged.
 */
(() => {
  const api = typeof browser !== "undefined" ? browser : chrome;

  const apply = (enabled) => {
    document.documentElement.classList.toggle("ytf-on", enabled);
  };

  api.storage.local.get({ enabled: true }).then(({ enabled }) => apply(enabled));

  api.storage.onChanged.addListener((changes, area) => {
    if (area === "local" && changes.enabled) {
      apply(changes.enabled.newValue);
    }
  });

  api.runtime.onMessage.addListener((msg) => {
    if (msg && msg.type === "ytf-toggle") {
      api.storage.local.get({ enabled: true }).then(({ enabled }) => {
        api.storage.local.set({ enabled: !enabled });
        apply(!enabled);
      });
    }
  });
})();
