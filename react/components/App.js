import React, { Component } from 'react';
import States from '../constants/States';

class App extends Component {
  constructor(props){
    super(props);
    this.state = {
      address: "",
      city: "",
      state: "",
      zip: "",
      zillowObject: null;
    };
    this.onAddressChange = this.onAddressChange.bind(this);
    this.onCityChange = this.onCityChange.bind(this);
    this.onStateChange = this.onStateChange.bind(this);
    this.onZipChange = this.onZipChange.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
  }

  onAddressChange(event) {
    this.setState({ address: event.target.value });
  }

  onCityChange(event) {
    this.setState({ city: event.target.value });
  }

  onStateChange(event) {
    this.setState({ state: event.target.value });
  }

  onZipChange(event) {
    this.setState({zip: event.target.value});
  }

  onSubmit(event) {
    event.preventDefault();

    let zillowKey = "X1-ZWz198oaiq7qq3_7x5fi";
    let addressQuery = this.state.address.replace(" ","+");
    let cityStateZipQuery;

    if (this.state.zip === null) {
      cityStateZipQuery = `${this.state.city}%2C+${this.state.state}`;
    } else {
      cityStateZipQuery = this.state.zip;
    }

    let proto_uri="http://www.zillow.com/webservice/GetSearchResults.htm?";
    proto_uri += `zws-id=${zillowKey}&`;
    proto_uri += `address=${addressQuery}&`;
    proto_uri += `citystatezip=${cityStateZipQuery}`;

    let uri=encodeURI(proto_uri);

    let zillowResponse;

    let parseString = require('xml2js').parseString;

    fetch(uri)
      .then(response => response.text())
      .then(xmlObject => {
        parseString(xmlObject, function(err,result) {
          zillowResponse = result["SearchResults:searchresults"]["response"][0]["results"][0]["result"][0]
          this.setState({ zillowObject: zillowResponse })
        });
      });

  }

  render() {

    let optionElements = States.map(option => {
      return (
        <option key={option} value={option}>{option}</option>
      )
    });

    return(
      <div>
        <form onSubmit={this.onSubmit}>
          <label>Address
            <input
              type="text"
              id="address"
              value={this.state.address}
              onChange={this.onAddressChange}/>
          </label>
          <label>City
            <input
              type="text"
              id="city"
              value={this.state.city}
              onChange={this.onCityChange}/>
          </label>
          <label>State
            <select
              id="state"
              onChange={this.onStateChange}
              value={this.state.state} >
              <option value=""></option>
              {optionElements}
            </select>
          </label>

          <label>Zip Code
            <input
              type="text"
              id="zip"
              value={this.state.zip}
              onChange={this.onZipChange}/>
          </label>
          <input type="submit" className="button" value="Submit" />
        </form>

      </div>
    )
  }
}

export default App;
