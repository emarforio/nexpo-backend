import React, { Component } from 'react';
import PropTypes from 'prop-types'

import {
  Table,
  TableBody,
  TableHeader,
  TableHeaderColumn,
  TableRow,
  TableRowColumn,
} from 'material-ui/Table';
import InvisibleLink from '../../Components/InvisibleLink';
import LoadingSpinner from '../../Components/LoadingSpinner';
import './Companies.css'
import { Helmet } from "react-helmet";

/**
 * Responsible for rendering a list of companies
 */
class Companies extends Component {

  _renderTableHeader() {
    return (
      <TableHeader>
        <TableRow>
          <TableHeaderColumn>Name</TableHeaderColumn>
          <TableHeaderColumn>Email</TableHeaderColumn>
        </TableRow>
      </TableHeader>
    )
  }

  _renderTableRow(company) {
    return (
      <TableRow key={company.id}>
        <TableRowColumn>
          <InvisibleLink to={`/companies/${company.id}`}>{company.name}</InvisibleLink>
        </TableRowColumn>
        <TableRowColumn>{company.email}</TableRowColumn>
      </TableRow>
    )
  }

  _renderLoading() {
    return (
      <div className="loading-spinner">
        <LoadingSpinner />
      </div>
    )
  }

  _renderCompanies() {
    return (
      <div>
        <Helmet>
          <title>Nexpo | Companies</title>
        </Helmet>
        <Table>
          {this._renderTableHeader()}
          <TableBody>
            {Object.keys(this.props.companies).map((key) => this._renderTableRow(this.props.companies[key])) }
          </TableBody>
        </Table>
      </div>
      )
  }


  render() {
    if(this.props.fetching) {
      return (
        this._renderLoading()
      )
    } else {
      return (
        this._renderCompanies()
      )
    }
  }
}

Companies.propTypes = {
  companies: PropTypes.object,
  fetching: PropTypes.bool
}

Companies.defaultProps = {
  companies: {},
  fetching: false
}

export default Companies
