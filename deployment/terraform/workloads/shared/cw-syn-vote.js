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
  
  // Randomly choose between dogs (a) and cats (b)
  const voteForDogs = Math.random() < 0.5;
  const selector = voteForDogs ? 
    'body > #content-container > #content-container-center #a' : 
    'body > #content-container > #content-container-center #b';
  
  await synthetics.executeStep('Click_1', async function() {
    await page.waitForSelector(selector)
    await page.click(selector)
    log.info(`Voted for ${voteForDogs ? 'dogs' : 'cats'}`)
  })
  
  await navigationPromise
  
};
exports.handler = async () => {
    return await recordedScript();
};
