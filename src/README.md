# Unobtrusive scripting support for AngularJS

This page keeps track of wiki page ([Unobtrusive-scripting-support-for-jQuery](https://github.com/rails/jquery-ujs/wiki/Unobtrusive-scripting-support-for-jQuery)) in [`jquery_ujs`](https://github.com/rails/jquery-ujs).

## Documentation

### "data-confirm": Confirmation dialogs for links and forms

```html
<form data-confirm="Are you sure you want to submit?">...</form>
```

The presence of this attribute indicates that activating a link or submitting a form should be intercepted so the user can be presented a JavaScript `confirm()` dialog containing the text that is the value of the attribute. If the user chooses to cancel, the action doesn't take place.

The attribute is also allowed on form submit buttons. This allows you to customize the warning message depending on the button which was activated. In this case, you should *not* also have "data-confirm" on the form itself.

### "data-method": Links that result in POST, PUT, or DELETE requests

```html
<a href="..." data-method="delete" rel="nofollow">Delete this entry</a>
```

Activating hyperlinks (usually by clicking or tapping on them) always results in an HTTP GET request. However, if your application is [RESTful](http://en.wikipedia.org/wiki/Representational_State_Transfer), some links are in fact actions that change data on the server and must be performed with non-GET requests. This attribute allows marking up such links with an explicit method such as "post", "put" or "delete".

The way it works is that, when the link is activated, it constructs a hidden form in the document with the "action" attribute corresponding to "href" value of the link and the method corresponding to "data-method" value, and submits that form.

Note for non-Rails backends: because submitting forms with HTTP methods other than GET and POST isn't widely supported across browsers, all other HTTP methods are actually sent over POST with the intended method indicated in the "_method" parameter. Rails framework automatically detects and compensates for this.

### "data-remote": Make links and forms submit asynchronously with Ajax

```html
    <form data-remote="modelName" action="...">
      <input type="text" name="name" ng-model="modelName.name">
    </form>
```

This attribute indicates that the link or form is to be submitted asynchronously; that is, without the page refreshing.

For `angularjs` apps, only inputs with `ng-model` will be submitted with `data-remote`.

## Not Supported Features

### "data-disable-with": Automatic disabling of links and submit buttons in forms
**NOT YET SUPPORTED**

### "data-type": Set Ajax request type for "data-remote" requests
**NOT SUPPORTED DUE TO `$http`**
