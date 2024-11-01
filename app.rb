require "sinatra"
require "ssoready"

ssoready = SSOReady::Client.new(api_key: "ssoready_sk_c7moz34g31py2s6szyaakcghc")

enable :sessions

get "/" do
    erb <<-EOS, locals: {session: session}
        <html>
            <head>
                <title>SAML Demo App using SSOReady</title>
                <script src="https://cdn.tailwindcss.com"></script>
            </head>
            <body>
                <main class="grid min-h-full place-items-center py-32 px-8">
                    <div class="text-center">
                        <h1 class="mt-4 text-balance text-5xl font-semibold tracking-tight text-gray-900 sm:text-7xl">
                            Hello, <%= session[:email] or "logged-out user" %>!
                        </h1>
                        <p class="mt-6 text-pretty text-lg font-medium text-gray-500 sm:text-xl/8">
                            This is a SAML demo app, built using SSOReady.
                        </p>

                        <!-- submitting this form makes the user's browser do a GET /saml-redirect?email=... -->
                        <form method="get" action="/saml-redirect" class="mt-10 max-w-lg mx-auto">
                            <div class="flex gap-x-4 items-center">
                                <label for="email-address" class="sr-only">Email address</label>
                                <input id="email-address" name="email" class="min-w-0 flex-auto rounded-md border-0 px-3.5 py-2 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6" value="john.doe@example.com" placeholder="john.doe@example.com">
                                <button type="submit" class="flex-none rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
                                    Log in with SAML
                                </button>
                                <a href="/logout" class="px-3.5 py-2.5 text-sm font-semibold text-gray-900">
                                    Sign out
                                </a>
                            </div>
                            <p class="mt-4 text-sm leading-6 text-gray-900">
                                (Try any @example.com or @example.org email address.)
                            </p>
                        </form>
                    </div>
                </main>
            </body>
        </html>
    EOS
end

get "/logout" do
    session.clear
    redirect("/")
end

get "/saml-redirect" do
    get_redirect_result = ssoready.saml.get_saml_redirect_url(
        organization_external_id: params[:email].split("@").last
    )
    redirect(get_redirect_result.redirect_url)
end

get "/ssoready-callback" do
    redeem_result = ssoready.saml.redeem_saml_access_code(saml_access_code: params[:saml_access_code])
    session[:email] = redeem_result.email
    redirect("/")
end
