import { actionTypes } from '../..';
import API from '../../../API';

export function getCompanyIsLoading() {
  return {
    type: actionTypes.FETCH_COMPANY
  };
}

export function getCompanySuccess(company) {
  return {
    type: actionTypes.FETCH_COMPANY_SUCCESS,
    company
  };
}

export type GetCompanyFailureAction = {
  type: string
};
export function getCompanyFailure(): GetCompanyFailureAction {
  return {
    type: actionTypes.FETCH_COMPANY_FAILURE
  };
}

export function getCompany(id) {
  return dispatch => {
    dispatch(getCompanyIsLoading());
    return API.companies
      .get(id)
      .then(company => {
        dispatch(getCompanySuccess(company.data));
      })
      .catch(() => {
        dispatch(getCompanyFailure());
      });
  };
}