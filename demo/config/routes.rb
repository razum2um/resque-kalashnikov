ResqueKalashnikovDemo::Application.routes.draw do

  mount Resque::Server, at: '/resque'

  match "test/home"

  match "test/slow"

  match "test/unreliable"

end
