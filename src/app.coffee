
Backbone = require('backbone')



class window.Address extends Backbone.Model
  constructor: ({@name, @m, @n} ={})->
    @keys = @genKeys()      
    @name ?= 'Untitled'
    @m ?= 1
    @n ?= 1
    @txs ?= 0

  genKeys: ->
    private: "05#{ Math.random() * 999999 }"
    public: "04#{ Math.random() * 999999 }"


class window.AddressCollection extends Backbone.Collection
  model: window.Address



addresses = window.addresses = new window.AddressCollection( [ new window.Address( name: 'Test' ) ] )


app = angular.module 'multiparty', ['ui.bootstrap', 'ngTouch']

app.controller 'AddressesCtrl', ['$scope', ($scope) ->
  collection = addresses
  $scope.addresses = collection.models
  $scope.collection = collection
]

app.controller 'CreateNewCtrl', ['$scope', '$modal', ($scope, $modal) ->
  CreateNewInstanceCtrl = ($scope, $modalInstance) ->

    $scope.address = new window.Address( name: 'Untitled' )

    $scope.ok = ->
      console.log 'ok', $scope.address, $scope.addresses
      addresses.add [$scope.address]
      $modalInstance.close()

    $scope.cancel = (x) ->
      console.log $scope, x
      # $modalInstance.dismiss('cancel')

  $scope.open = (size) ->
    modal = $modal.open
      templateUrl: '/create_new.html'
      controller: CreateNewInstanceCtrl
      size: size
]





app.controller 'AddressCtrl', ['$scope', '$modal', ($scope, $modal) ->
  AddressInstanceCtrl = ($scope, $modalInstance, address) ->
    $scope.address = address 
    console.log 'address instance ctrl', $scope, $modalInstance, address
    $scope.back = ->
      $modalInstance.dismiss('cancel')

  $scope.show = (address) ->
    console.log address, $scope
    modal = $modal.open
      templateUrl: '/address.html'
      controller: AddressInstanceCtrl
      resolve:
        address: -> address
]




app.controller 'EntropyCtrl', ['$scope', ($scope) ->
  $scope.clse = false
  $scope.done = false
  $scope.max = 100
  $scope.value = 0
  $scope.entropy = 0
  $scope.type = 'info'

  $scope.addEntropy = ($event) =>
    unless $scope.done or $scope.wait
      $scope.entropy = $scope.entropy + $event.pageX
      $scope.value = $scope.value + 1
      $scope.wait = true
      setTimeout ( -> $scope.wait = false ), 4
      if $scope.value >= 100
        $scope.type = 'success'
        $scope.done = true
]