import { LightningElement, track } from 'lwc';

export default class GoogleSearchYushin extends LightningElement {
    @track searchTerm = '';
    @track searchResults;
    @track name;
    @track nativeName;
    @track hqLoc;
    @track hqLocCity;
    @track hqLocCountry;
    @track revenue;
    @track revenueYear;
    @track numEmp;
    @track numEmpYear;

    handleSearchTermChange(event) {
      this.searchTerm = event.target.value;
    }

    searchGoogle() {
      if (!this.searchTerm) return;

      const query = encodeURIComponent(this.searchTerm);
      const apiKey = 'AIzaSyC1tUwhST9DmHFXofayEbKpX-MXLipq-FY'; // Replace with your Google API key
      const customSearchEngineId = 'e48b9b6c5aee3454e'; // Replace with your Custom Search Engine ID

      const apiUrl = `https://www.googleapis.com/customsearch/v1?q=${query}&cx=${customSearchEngineId}&key=${apiKey}`;

      fetch(apiUrl)
        .then((response) => {
          if (!response.ok) {
            throw new Error('Network response was not ok.');
          }
          return response.json();
        })
        .then((data) => {
          if (data && data.items) {
            this.searchResults = data.items.map((item) => ({
              title: item.title,
              link: item.link,
            }));
          }
        })
        .then(() => {
          let urlsplit;
          for (const ele in this.searchResults) {
            if (this.searchResults[ele].link.includes("wikipedia.org/wiki/")) {
              urlsplit = this.searchResults[ele].link.split("/wiki/")[1];
              const searchTerm = urlsplit.replace(/_/g, " ");
              const wikiAPI = `https://en.wikipedia.org/w/api.php?origin=*&action=query&format=json&titles=${encodeURIComponent(searchTerm)}&prop=revisions&rvprop=content&rvsection=0`;

              fetch(wikiAPI)
                .then((response) => response.json())
                .then((data) => {
                  const pages = data.query.pages;
                  const pageId = Object.keys(pages)[0];
                  const pageData = pages[pageId];
                  const content = pageData.revisions[0]["*"];
                  console.log(content);

                  const infoboxRegex = /\{\{Infobox[\s\S]*?\}\}\n\n/i;
                  const infoboxMatch = content.match(infoboxRegex);
                  const infoboxContent = infoboxMatch[0];
                  console.log(infoboxMatch[0]);

                  const nameRegex = /\|\s*name\s*=\s*(.*)/i;
                  const nativeNameRegex = /\|\s*native_name\s*=\s*(.*)/i;
                  const hqLocRegex = /\|\s*hq_location\s*=\s*(.*)/i;
                  const hqLocCityRegex = /\|\s*hq_location_city\s*=\s*\[\[([^\[\]]+)\]\]/i;
                  const hqLocCountryRegex = /\|\s*hq_location_country\s*=\s*\[\[([^\[\]]+)\]\]/i;
                  const revenueRegex = /\|\s*revenue\s*=\s*\[\[[^\]]+\|(.+?)\]\]\s*([\d.]+\s*\w+)/i;
                  const revenueYearRegex = /\|\s*revenue_year\s*=\s*(.*)/i;
                  const numEmpRegex = /\|\s*num_employees\s*=\s*(.*)/i;
                  const numEmpYearRegex = /\|\s*num_employees_year\s*=\s*(.*)/i;

                  this.name = infoboxContent.match(nameRegex) ? infoboxContent.match(nameRegex)[1] : null;
                  this.nativeName = infoboxContent.match(nativeNameRegex) ? infoboxContent.match(nativeNameRegex)[1] : null;
                  this.hqLoc = infoboxContent.match(hqLocRegex) ? infoboxContent.match(hqLocRegex)[1] : null;
                  this.hqLocCity = infoboxContent.match(hqLocCityRegex) ? infoboxContent.match(hqLocCityRegex)[1] : null;
                  this.hqLocCountry = infoboxContent.match(hqLocCountryRegex) ? infoboxContent.match(hqLocCountryRegex)[1] : null;
                  this.revenue = infoboxContent.match(revenueRegex) ? infoboxContent.match(revenueRegex)[2] + " " + infoboxContent.match(revenueRegex)[1] : null;
                  this.revenueYear = infoboxContent.match(revenueYearRegex) ? infoboxContent.match(revenueYearRegex)[1] : null;
                  this.numEmp = infoboxContent.match(numEmpRegex) ? infoboxContent.match(numEmpRegex)[1] : null;
                  this.numEmpYear = infoboxContent.match(numEmpYearRegex) ? infoboxContent.match(numEmpYearRegex)[1] : null;
                })
                .catch((err) => {
                  console.error("Error fetching Wikipedia data", err);
                });
            }
          }
        })
        .catch((error) => {
          console.error('Error fetching search results:', error);
        });
    }

}