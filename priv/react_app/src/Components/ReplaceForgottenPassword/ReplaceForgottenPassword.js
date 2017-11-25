import React, {Component} from 'react'
import './ReplaceForgottenPassword.css'
import PropTypes from 'prop-types'
import TextField from 'material-ui/TextField'
import RaisedButton from 'material-ui/RaisedButton'
import ErrorMessage from './../ErrorMessage'

type Props = {
  sendNewPasswordToBackend: func,
  hashKey: string,
  verifyKey: func,
  keyIsValid: bool,
  errors: {
    password: string[],
    password_confirmation: string[]
  }
}

class ReplaceForgottenPassword extends Component<Props> {
  static propTypes = {
    verifyKey: PropTypes.func.isRequired,
    sendNewPasswordToBackend: PropTypes.func.isRequired,
    hashKey: PropTypes.string.isRequired,
    keyIsValid: PropTypes.bool.isRequired,
    errors: PropTypes.object.isRequired
  }

  static defaultProps = {
    errors: {}
  }

  state = {
    password: '',
    password_confirmation: ''
  }

  componentDidMount() {
    this.props.verifyKey()
  }

  _setPassword = (val) => {
    this.setState({password: val})
  }

  _setPasswordConfirmation = (val) => {
    this.setState({password_confirmation: val})
  }

  _sendQueryToBackend = () => {
    const {password, password_confirmation} = this.state
    this.props.sendNewPasswordToBackend({password, password_confirmation})
  }

  render() {
    let {keyIsValid, errors} = this.props
    errors = {
      password: errors.password || [],
      password_confirmation: errors.password_confirmation || []
    }

    if(!keyIsValid) {
      return (
        <ErrorMessage
          message="This link does not seem to exist"
        />
      )
    }

    return (
      <div className="ReplaceForgottenPassword_Component">
        <h1>Replace password</h1>
        <TextField
          floatingLabelText="New password"
          type='password'
          value={this.state.password}
          onChange={(e, val) => this._setPassword(val)}
          errorText={errors.password.length > 0 ? errors.password[0] : ''}
        />
        <TextField
          floatingLabelText="Confirm new password"
          type='password'
          value={this.state.password_confirmation}
          onChange={(e, val) => this._setPasswordConfirmation(val)}
          errorText={errors.password_confirmation.length > 0 ? errors.password_confirmation[0] : ''}
        />
        <br/>
        <RaisedButton
          label="Update password"
          primary
          onTouchTap={this._sendQueryToBackend}
        />
      </div>
    )
  }
}

export default ReplaceForgottenPassword
