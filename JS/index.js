import * as cheerio from 'cheerio'

export class Analyzer {
  static analyze(html, word) {


    if (typeof nativeLog === 'function') { nativeLog('Analyzing') }
    const result = Analyzer.getDefinitions(html, word)
    return result;
  }
  static getSuggestion(html) {
    const $ = cheerio.load(html);
    const suggestion = $('.e19m0k9k1').first().text()
    return suggestion;
  }

  static getDefinitionList($, elem) {
    const definitionListData = $(elem).find('.e1q3nk1v3');
    var definitionList = new Object();

    const category = $(elem).find('.luna-pos');

    definitionList.category = category.text();
    definitionList.definitions = []

    definitionListData.each((i, elem) => {
      const definition = Analyzer.getDefinition($, elem)
      definitionList.definitions.push(definition);
    });
    return definitionList
  }

  static getDefinition($, elem) {
    const definitionData = $(elem).find('.e1q3nk1v4');
    const definition = new Object();
    definitionData.each((i, elem) => {
      if ($(elem).children().first().hasClass('luna-labset')) {
        const label = $(elem).find('.luna-label').text();
        definition.label = label;
      } else {
        const example = $(elem).find('.luna-example').text();
        $(elem).find('.luna-example').remove();
        definition.example = example;

        var description = $(elem).text()
        definition.description = description;
 
      }
    });

    return definition;
  }

  static getDefinitions(html, name) {

    const $ = cheerio.load(html);
    const items = $('.no-collapse').eq(1).prevAll().toArray().reverse();

    var word = new Object();
    word.name = name;
    word.definitionLists = [];
  
    $(items).each((i, elem) => {
      // var definitions = new Object();
      if ($(elem).hasClass('e1hk9ate0')) {
        const definitionList = Analyzer.getDefinitionList($, elem)
        word.definitionLists.push(definitionList);

      } else {
        $(elem).find('.e1hk9ate0').each((i, elem) => {
          const definitionList = Analyzer.getDefinitionList($, elem)
          word.definitionLists.push(definitionList);

        });
      }
    });
    return word;
  }


  static getDatabaseDefintions(html, word) {

    if (typeof nativeLog === 'function') { nativeLog('Analyzing') }

    const $ = cheerio.load(html);
    const items = $('p');
    var defintions = []
    $(items).each((i, elem) => {

      defintions[i] = $(elem).text();
    });
    
    return defintions;
  }

  
};
