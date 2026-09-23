/**
 * Theater Fill for YouTube — background service worker.
 *
 * Clicking the toolbar button toggles the fill behavior on the active tab
 * by messaging the content script. On non-YouTube tabs there is no content
 * script, so the message is simply dropped.
 */
const api = typeof browser !== "undefined" ? browser : chrome;

api.action.onClicked.addListener(async (tab) => {
  if (!tab || !tab.id) return;
  try {
    await api.tabs.sendMessage(tab.id, { type: "ytf-toggle" });
  } catch {
    // Content script not present on this tab — nothing to toggle.
  }
});
