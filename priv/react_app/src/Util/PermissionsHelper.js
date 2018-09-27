/**
 * A helper class for handling user permissions, currently only handles read
 */
const routePermissions = {
  categories: ['read_all', 'read_categories'],
  companies: ['read_all', 'read_companies'],
  roles: ['read_all', 'read_roles'],
  users: ['read_all', 'read_users'],
  events: ['read_all', 'read_events'],
  sessions: ['read_all', 'read_sessions'],
  hosts: ['read_all', 'read_hosts']
};

const getBasePath = route => route.split('/').filter(i => i)[0];

export const hasPermission = (currentUser, route) => {
  const basePath = getBasePath(route);
  const permissionsNeeded = routePermissions[basePath];
  if (!currentUser) {
    return false;
  }
  if (permissionsNeeded) {
    const { roles = [] } = currentUser;
    return roles.some(role => {
      return role.permissions.some(p => permissionsNeeded.includes(p));
    });
  }
  return true;
};

export default { hasPermission };
