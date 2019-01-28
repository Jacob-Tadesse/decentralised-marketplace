import React from "react";
import {
  AccountData,
  ContractData,
  ContractForm,
} from "drizzle-react-components";
import PropTypes from 'prop-types';

class MyComponent extends React.Component {
  constructor(props, context) {
    super(props);
    this.contracts = context.drizzle.contracts;
  }

  state = { dataKey: null};

  componentDidMount() {
    const dataKey = this.contracts.Admin.methods["getStoreFrontsandStoreIDs"].cacheCall();
    this.setState({ dataKey });
  }

  render() {
      return(
          <ContractData
              contract="Admin"
              method="getStoreFrontsandStoreIDs"
          />
      );
  }
}
MyComponent.contextTypes = {
  drizzle: PropTypes.object
}
export default MyComponent;
