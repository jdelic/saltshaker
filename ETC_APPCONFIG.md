/etc/appconfig Application resources and configuration
======================================================

 * Each application using `/etc/appconfig` has its own subfolder there. For
   example: `/etc/appconfig/authserver/`

 * Each appconfig folder contains at least the following reserved subfolders:
   `env` and `files`.

     - `env` is an *envdir* containing files whose contents are exported as
       environment variables for the application.

     - `files` contains configuration files and other artifacts (like SSL
       certificates) used by the application. These files are often referred
       to by the configuration in `env`.
