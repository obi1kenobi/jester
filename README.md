# jester
An authentication system that enables two-factor authentication (2FA) using only client-side Javascript, without relying on any special server-side APIs other than password-based login and password changes for authenticated users. Jester is a proof-of-concept Chrome extension, however, in principle it is also possible to implement the same protocol in a mobile app.

## Using Jester
If you have used a software-based 2FA tool such as [Google Authenticator](https://support.google.com/accounts/answer/1066447?hl=en), Jester should feel very familiar. After you set up Jester for a particular account, it will allow you to request a random numeric token valid for a brief period of time, which you will be able to use to log in.

After adding Jester to your browser, please make sure that:
- your Chrome browser is version 42 or newer, and
- the "Allow in incognito" checkbox for Jester in the Chrome Extensions settings page is checked.

Jester uses Chrome's incognito mode in order to ensure no session data (such as cookies or HTML5 local storage) is left over after account operations such as logging in or changing passwords.

### Setting up Jester
Jester requires that you set up a password before you use it, which will be used to encrypt all your data. This password is not stored anywhere, so you'll need to enter it every time you use Jester. To protect your data, Jester will automatically close after a brief period of inactivity.

### Setting up 2FA for an account
Jester currently has [configuration data](https://github.com/obi1kenobi/jester/blob/master/src/js/extension/services/service_data.coffee) for a limited set of websites (PRs adding more are appreciated). To set up a 2FA profile for that account, open the "Add new" tab, select the website and enter your credentials. Jester will then verify those credentials and change the password on that account to a long, randomly-generated string. From that point on, you will need Jester in order to log into that account.

### Using Jester 2FA
After creating a 2FA profile for a given account, Jester will display that account in the "Home" tab. To log into that account using Jester 2FA, click the "Get token" button. Jester will generate and display a numeric token, and set your account password to the concatenation of your original password and the numeric token. For example, if your password before using Jester was `mypassword` and the token is `123456`, Jester will change the account password to `mypassword123456`. Since you already know your original password for the account, and Jester displays the token, you will now be able to log into your account by entering the original password + token into the password field on the website.

After a brief interval, Jester will automatically revoke the token by logging back into the website and changing the account password to a new randomly generated string. If the token expired and was revoked before you were able to log in, you can request a new token in the same fashion.

### Repairing a profile
Occasionally, some of your 2FA profiles may enter an unexpected state and will be deactivated until repaired. This could happen, for example, if the browser was closed before Jester finished an operation, due to a network connectivity problem, or due to a website error. On startup, Jester will automatically attempt to repair any deactivated profiles. You may also manually direct it to attempt repair on a profile by clicking the "Repair" button that appears on deactivated profiles.

## Development

- `npm install`
- `npm install -g grunt-cli`

Add Jester to Chrome (as explained above), and make sure to reload it after every grunt rebuild.

## Testing
To run the tests, you need to do two things:
- from the `scripts` directory, execute `run_selenium.sh`
- then, run `grunt test` in the main project directory
