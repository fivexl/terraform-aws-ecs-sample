var synthetics = require('Synthetics');
const log = require('SyntheticsLogger');

const recordedScript = async function () {
  let page = await synthetics.getPage();
  
  const navigationPromise = page.waitForNavigation()
  
  await synthetics.executeStep('Goto_0', async function() {
    await page.authenticate({ 
      username: process.env.AUTH_USERNAME, 
      password: process.env.AUTH_PASSWORD 
    });
    await page.goto("https://vote.fivexl.dev/", {waitUntil: 'domcontentloaded', timeout: 60000})
  })
  
  await page.setViewport({ width: 1710, height: 981 })
  
  await synthetics.executeStep('Click_1', async function() {
    await page.waitForSelector('body > #content-container > #content-container-center #b')
    await page.click('body > #content-container > #content-container-center #b')
  })
  
  await navigationPromise
  
};
exports.handler = async () => {
    return await recordedScript();
};