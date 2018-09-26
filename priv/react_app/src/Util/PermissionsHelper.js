/**
 * A helper class for handling user permissions, currently only handles read
 */
const routePermissions = {
  categories: ['read_all', 'read_categories'],
  companies: ['read_all', 'read_companies'],
  roles: ['read_all', 'read_roles'],
  users: ['read_all', 'read_users'],
  events: ['read_all', 'read_events'],
  student_sessions: ['read_all', 'read_student_sessions'],
  host_applications: ['read_all', 'read_host_applications']
};

const getBasePath = route => route.split('/').filter(i => i)[0];

export const hasPermission = (currentUser, route) => {
  const basePath = getBasePath(route);
  if (currentUser && currentUser.roles) {
    const { roles } = currentUser;
    const allowed = roles.some(role => {
      const permissionsNeeded = routePermissions[basePath];
      return role.permissions.some(p => permissionsNeeded.includes(p));
    });
    return allowed;
  }
  return false;
};