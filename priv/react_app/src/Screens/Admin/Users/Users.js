import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Table, Divider, Popconfirm } from 'antd';

import InvisibleLink from '../../../Components/InvisibleLink';
import LoadingSpinner from '../../../Components/LoadingSpinner';
import HtmlTitle from '../../../Components/HtmlTitle';

/**
 * Responsible for rendering a list of users
 */
class Users extends Component {
  componentWillMount() {
    const { getAllUsers } = this.props;
    getAllUsers();
  }

  renderUsers() {
    const { users } = this.props;
    const userColumns = [
      {
        title: 'Email',
        dataIndex: 'email',
        key: 'email',
        render: (email, { id }) => (
          <InvisibleLink to={`/admin/users/${id}`}>{email}</InvisibleLink>
        )
      },
      {
        title: 'First Name',
        dataIndex: 'firstName',
        key: 'firstName'
      },
      {
        title: 'Last Name',
        dataIndex: 'lastName',
        key: 'lastName'
      },
      {
        title: 'Action',
        key: 'action',
        render: user => (
          <span>
            <InvisibleLink to={`/admin/users/${user.id}`}>Show</InvisibleLink>
            <Divider type="vertical" />
            <InvisibleLink to={`/admin/users/${user.id}/edit`}>
              Edit
            </InvisibleLink>
            <Divider type="vertical" />
            <Popconfirm
              title="Sure to delete?"
              onConfirm={() => this.props.deleteUser(user.id)}
            >
              <span style={{ color: '#ff4d4f', cursor: 'pointer' }}>
                Delete
              </span>
            </Popconfirm>
          </span>
        )
      }
    ];

    return (
      <div>
        <HtmlTitle title="Users" />

        <h1>Users</h1>

        <Table
          columns={userColumns}
          dataSource={Object.keys(users).map(i => ({
            ...users[i],
            key: i
          }))}
        />
      </div>
    );
  }

  render() {
    if (this.props.fetching) {
      return <LoadingSpinner />;
    }
    return this.renderUsers();
  }
}

Users.propTypes = {
  users: PropTypes.object.isRequired,
  fetching: PropTypes.bool.isRequired,
  getAllUsers: PropTypes.func.isRequired
};

Users.defaultProps = {
  users: {},
  fetching: false
};

export default Users;
