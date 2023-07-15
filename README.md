How This Looks in Rails
Let's look at what the simplest possible login system might look like in a Rails API/React application.

The flow will look like this:

The user navigates to a login form on the React frontend.
The user enters their username. There is no password (for now).
The user submits the form, POSTing to /login on the Rails backend.
In the create action of the SessionsController we set a cookie on the user's browser by writing their user ID into the session hash.
Thereafter, the user is logged in. session[:user_id] will hold their user ID.
Let's write a SessionsController to handle our login route. This controller has one action, create, which we'll map in routes.rb for POST requests to /login:

post "/login", to: "sessions#create"
Typically, your create method would look up a user in the database, verify their login credentials, and then store the authenticated user's id in the session:

class SessionsController < ApplicationController
  def create
    user = User.find_by(username: params[:username])
    session[:user_id] = user.id
    render json: user
  end
end
There's no way for the server to log you out right now. To log yourself out, you'll have to delete the cookie from your browser.

Here's what the login component might look like on the frontend:

function Login({ onLogin }) {
  const [username, setUsername] = useState("");

  function handleSubmit(e) {
    e.preventDefault();
    fetch("/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ username }),
    })
      .then((r) => r.json())
      .then((user) => onLogin(user));
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        value={username}
        onChange={(e) => setUsername(e.target.value)}
      />
      <button type="submit">Login</button>
    </form>
  );
}
When the user submits the form, they'll be logged in! Our onLogin callback function would handle saving the logged in user's details in state.

Staying Logged In
Using the wristband analogy, in the example above, we've shown our ID at the door (username) and gotten our wristband (session[:user_id]) from the backend. So our backend has a means of identifying us with each request using the session hash.

Our frontend also knows who we are, because our user data was saved in state after logging in.

What happens now if we leave the club and try to come back in, by refreshing the page on the frontend? Well, our frontend doesn't know who we are any more, since we lose our frontend state after refreshing the page. Our backend does know who we are though — so we need a way of getting the user data from the backend into state when the page first loads.

Here's how we might accomplish that. First, we need a route to retrieve the user's data from the database using the session hash:

get "/me", to: "users#show"
And a controller action:

class UsersController < ApplicationController
  def show
    user = User.find_by(id: session[:user_id])
    if user
      render json: user
    else
      render json: { error: "Not authorized" }, status: :unauthorized
    end
  end
end
Then, we can try to log the user in from the frontend as soon as the application loads:

function App() {
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetch("/me").then((response) => {
      if (response.ok) {
        response.json().then((user) => setUser(user));
      }
    });
  }, []);

  if (user) {
    return <h2>Welcome, {user.username}!</h2>;
  } else {
    return <Login onLogin={setUser} />;
  }
}
This is the equivalent of letting someone use their wristband to come back into the club.

Logging Out
The log out flow is even simpler. We can add a new route for logging out:

delete "/logout", to: "sessions#destroy"
Then add a SessionsController#destroy method, which will clear the username out of the session:

def destroy
  session.delete :user_id
  head :no_content
end
Here's how that might look in the frontend:

function Navbar({ onLogout }) {
  function handleLogout() {
    fetch("/logout", {
      method: "DELETE",
    }).then(() => onLogout());
  }

  return (
    <header>
      <button onClick={handleLogout}>Logout</button>
    </header>
  );
}
The onLogout callback function would handle removing the information about the user from state.

Conclusion
At its base, login is very simple: the user provides you with credentials by filling out a form, you verify those credentials and set a token in the session. In this example, our token was their user id. We can also log users out by removing their user ID from the session.

Check For Understanding
Before you move on, make sure you can answer the following questions:

In the login and authentication flow you learned in this lesson for Rails API/React applications, in what two places is authentication information stored?
In the login and authentication flow you learned in this lesson, what sequence of events happens if the user refreshes the page?

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
