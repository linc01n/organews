# @App.Adapter = @App.Adapter || DS.RESTAdapter.reopen
@App.Adapter = DS.RESTAdapter.reopen
	url: 'http://localhost:5100'
	namespace: 'v1'

@App.Store = DS.Store.extend
  revision: 12
  adapter: 'App.Adapter'


