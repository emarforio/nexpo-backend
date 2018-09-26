define({ "api": [  {    "type": "POST",    "url": "/categories/",    "title": "Create category",    "name": "Create_Category",    "group": "Category",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "title",            "description": "<p>Title</p>"          }        ]      }    },    "success": {      "fields": {        "Created 201": [          {            "group": "Created 201",            "type": "Number",            "optional": false,            "field": "id",            "description": "<p>Internal ID</p>"          },          {            "group": "Created 201",            "type": "String",            "optional": false,            "field": "title",            "description": "<p>Title</p>"          }        ]      }    },    "version": "0.0.0",    "filename": "web/controllers/category_controller.ex",    "groupTitle": "Category",    "error": {      "fields": {        "UnprocessableEntity 422": [          {            "group": "UnprocessableEntity 422",            "type": "Object",            "optional": false,            "field": "errors",            "description": "<p>Object containing errors</p>"          },          {            "group": "UnprocessableEntity 422",            "type": "String[]",            "optional": false,            "field": "errors.[unprocessable-key]",            "description": "<p>Array of String error messages</p>"          }        ]      },      "examples": [        {          "title": "UnprocessableEntity",          "content": "HTTP 422 Unprocessable Entity\n{\n  \"errors\": {\n    \"title\": [\n      \"can't be blank\"\n    ]\n  }\n}",          "type": "json"        },        {          "title": "Internal server error",          "content": "HTTP 500 Internal server error",          "type": "json"        }      ]    }  },  {    "type": "GET",    "url": "/categories",    "title": "List categories",    "group": "Category",    "success": {      "examples": [        {          "title": "Success",          "content": "HTTP 200 Ok\n{\n  \"data\": [\n    {\n      \"id\": 1,\n      \"title\": \"Example category\",\n      \"attributes\": []\n      },\n      {\n        \"id\": 2,\n        \"title\": \"Other category\",\n        \"attributes\": []\n      }\n    ]\n  }",          "type": "json"        }      ]    },    "version": "0.0.0",    "filename": "web/controllers/category_controller.ex",    "groupTitle": "Category",    "name": "GetCategories",    "error": {      "examples": [        {          "title": "Not Found",          "content": "HTTP 404 Not Found",          "type": "json"        },        {          "title": "Internal server error",          "content": "HTTP 500 Internal server error",          "type": "json"        }      ]    }  },  {    "type": "GET",    "url": "/categories/:id",    "title": "Get category",    "group": "Category",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "Number",            "optional": false,            "field": "id",            "description": "<p>ID of the category</p>"          }        ]      }    },    "success": {      "fields": {        "OK 200": [          {            "group": "OK 200",            "type": "Number",            "optional": false,            "field": "id",            "description": "<p>Internal ID</p>"          },          {            "group": "OK 200",            "type": "String",            "optional": false,            "field": "title",            "description": "<p>Title</p>"          }        ]      },      "examples": [        {          "title": "Success",          "content": "HTTP 200 Ok\n{\n  \"data\": {\n    \"id\": 1,\n    \"title\": \"Example category\",\n    \"attributes\": []\n  }\n}",          "type": "json"        }      ]    },    "version": "0.0.0",    "filename": "web/controllers/category_controller.ex",    "groupTitle": "Category",    "name": "GetCategoriesId",    "error": {      "examples": [        {          "title": "Not Found",          "content": "HTTP 404 Not Found",          "type": "json"        },        {          "title": "Internal server error",          "content": "HTTP 500 Internal server error",          "type": "json"        }      ]    }  },  {    "type": "GET",    "url": "/companies",    "title": "List companies",    "group": "Company",    "success": {      "examples": [        {          "title": "Success",          "content": "HTTP 200 Ok\n{\n  \"data\": [\n    {\n      \"id\": 1,\n      \"name\": \"CodeComp\",\n      \"description\": \"We do code!\"\n    },\n    {\n      \"id\": 2,\n      \"name\": \"Other Comp\",\n      \"description\": \"We do other things!\"\n    }\n  ]\n}",          "type": "json"        }      ]    },    "version": "0.0.0",    "filename": "web/controllers/company_controller.ex",    "groupTitle": "Company",    "name": "GetCompanies",    "error": {      "examples": [        {          "title": "Internal server error",          "content": "HTTP 500 Internal server error",          "type": "json"        }      ]    }  },  {    "type": "GET",    "url": "/companies/:id",    "title": "Get company",    "group": "Company",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "Number",            "optional": false,            "field": "id",            "description": "<p>ID of the company</p>"          }        ]      }    },    "success": {      "examples": [        {          "title": "Success",          "content": "HTTP 200 Ok\n{\n  \"data\": {\n    \"id\": 1,\n    \"name\": \"CodeComp\"\n  }\n}",          "type": "json"        }      ]    },    "version": "0.0.0",    "filename": "web/controllers/company_controller.ex",    "groupTitle": "Company",    "name": "GetCompaniesId",    "error": {      "examples": [        {          "title": "Not Found",          "content": "HTTP 404 Not Found",          "type": "json"        },        {          "title": "Internal server error",          "content": "HTTP 500 Internal server error",          "type": "json"        }      ]    }  },  {    "type": "GET",    "url": "/password/forgot/:key",    "title": "Verify password forgotten",    "group": "Forgot_password",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "key",            "description": "<p>Key representing a password reset</p>"          }        ]      }    },    "success": {      "examples": [        {          "title": "Success",          "content": "HTTP 200 OK\n{\n  \"type\": \"message\",\n  \"data\": \"Exists\"\n}",          "type": "json"        }      ]    },    "version": "0.0.0",    "filename": "web/controllers/user_controller.ex",    "groupTitle": "Forgot_password",    "name": "GetPasswordForgotKey",    "error": {      "examples": [        {          "title": "Not Found",          "content": "HTTP 404 Not Found",          "type": "json"        },        {          "title": "Bad Request",          "content": "HTTP 400 Bad Request",          "type": "json"        }      ]    }  },  {    "type": "POST",    "url": "/password/forgot",    "title": "Init reset of password",    "group": "Forgot_password",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "email",            "description": "<p>Email of user</p>"          }        ]      }    },    "success": {      "examples": [        {          "title": "Success",          "content": "HTTP 200 OK\n{\n  \"type\": \"message\",\n  \"data\": \"Sending email if user exists\"\n}",          "type": "json"        }      ]    },    "version": "0.0.0",    "filename": "web/controllers/user_controller.ex",    "groupTitle": "Forgot_password",    "name": "PostPasswordForgot",    "error": {      "examples": [        {          "title": "Bad Request",          "content": "HTTP 400 Bad Request",          "type": "json"        }      ]    }  },  {    "type": "POST",    "url": "/password/new/:key",    "title": "Reset forgotten password",    "group": "Forgot_password",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "key",            "description": "<p>Key representing this password reset</p>"          },          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "password",            "description": "<p>New password</p>"          },          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "password_confirmation",            "description": "<p>Confirmation of password</p>"          }        ]      }    },    "success": {      "examples": [        {          "title": "Success",          "content": "HTTP 200 OK\n{\n  \"type\": \"message\",\n  \"data\": \"Successfully changed password\"\n}",          "type": "json"        }      ]    },    "version": "0.0.0",    "filename": "web/controllers/user_controller.ex",    "groupTitle": "Forgot_password",    "name": "PostPasswordNewKey",    "error": {      "examples": [        {          "title": "Not Found",          "content": "HTTP 404 Not Found",          "type": "json"        },        {          "title": "Bad Request",          "content": "HTTP 400 Bad Request",          "type": "json"        }      ]    }  },  {    "type": "POST",    "url": "/login",    "title": "Login",    "group": "Login",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "email",            "description": "<p>Username</p>"          },          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "password",            "description": "<p>Password</p>"          }        ]      }    },    "success": {      "examples": [        {          "title": "Success",          "content": "HTTP 201 Created\n{\n  \"data\": {\n    \"jwt\": \"randomly-generated-string\"\n  }\n}",          "type": "json"        }      ]    },    "version": "0.0.0",    "filename": "web/controllers/session_controller.ex",    "groupTitle": "Login",    "name": "PostLogin",    "error": {      "examples": [        {          "title": "Bad Request",          "content": "HTTP 400 Bad Request",          "type": "json"        },        {          "title": "Unauthorized",          "content": "HTTP 401 Unauthorized",          "type": "json"        }      ]    }  },  {    "type": "GET",    "url": "/initial_signup/:signup_key",    "title": "Get current signup",    "group": "Sign_up",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "signup_key",            "description": "<p>Signup key of user</p>"          }        ]      }    },    "success": {      "examples": [        {          "title": "Success",          "content": "HTTP 200 Created\n{\n  \"data\": {\n    \"id\": 1,\n    \"email\": \"username@domain\"\n    \"first_name\": \"Benjamin\",\n    \"last_name\": \"Franklin\",\n  }\n}",          "type": "json"        }      ]    },    "version": "0.0.0",    "filename": "web/controllers/signup_controller.ex",    "groupTitle": "Sign_up",    "name": "GetInitial_signupSignup_key",    "error": {      "examples": [        {          "title": "Not Found",          "content": "HTTP 404 Not Found",          "type": "json"        }      ]    }  },  {    "type": "POST",    "url": "/final_signup/:signup_key",    "title": "Finish sign up",    "group": "Sign_up",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "signup_key",            "description": "<p>Signup key of user</p>"          },          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "password",            "description": "<p>Wanted password</p>"          },          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "password_confirmation",            "description": "<p>Confirmation of password</p>"          },          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "first_name",            "description": "<p>First name</p>"          },          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "last_name",            "description": "<p>Last name</p>"          }        ]      }    },    "success": {      "examples": [        {          "title": "Success",          "content": "HTTP 200 OK\n{\n  \"data\": {\n    \"id\": 1,\n    \"email\": \"username@student.lu.se\"\n    \"first_name\": \"Benjamin\",\n    \"last_name\": \"Franklin\",\n  }\n}",          "type": "json"        }      ]    },    "version": "0.0.0",    "filename": "web/controllers/signup_controller.ex",    "groupTitle": "Sign_up",    "name": "PostFinal_signupSignup_key",    "error": {      "examples": [        {          "title": "Not Found",          "content": "HTTP 404 Not Found",          "type": "json"        },        {          "title": "Bad Request",          "content": "HTTP 400 Bad Request",          "type": "json"        }      ]    }  },  {    "type": "POST",    "url": "/initial_signup",    "title": "Initiate sign up",    "group": "Sign_up",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "String",            "optional": false,            "field": "email",            "description": ""          }        ]      }    },    "success": {      "examples": [        {          "title": "Success",          "content": "HTTP 201 Created\n{\n  \"data\": {\n    \"id\": 1,\n    \"email\": \"username@domain\"\n    \"first_name\": null,\n    \"last_name\": null,\n  }\n}",          "type": "json"        }      ]    },    "version": "0.0.0",    "filename": "web/controllers/signup_controller.ex",    "groupTitle": "Sign_up",    "name": "PostInitial_signup",    "error": {      "examples": [        {          "title": "Bad Request",          "content": "HTTP 400 Bad Request",          "type": "json"        }      ]    }  }] });
