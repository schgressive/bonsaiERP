AttachmentController = ($scope, $http, $timeout, $upload) ->
  $scope.imageFor = (attachment) ->
    if attachment.image
      attachment.small_attachment_url
    else
      '/assets/back-gray.png'

  #
  $scope.upPosition = (index) ->
    tmp = $scope.attachments[index - 1]
    return  unless tmp

    $scope.attachments[index - 1] = $scope.attachments[index]
    $scope.attachments[index] = tmp

  #
  $scope.downPosition = (index) ->
    tmp = $scope.attachments[index + 1]
    return  unless tmp

    $scope.attachments[index + 1] = $scope.attachments[index]
    $scope.attachments[index] = tmp


  #
  $scope.delete = (attch, index) ->
    return  if attch.process

    if confirm('Esta segur@ de eliminar el adjunto?')

      attch.process = true

      $http.delete("/attachments/#{ attch.id }")
      .success( ->
        $scope.attachments.splice(index, 1)
      )
      .error(->
        alert('Existio un error al eliminar el adjunto')
      )
      .finally(->
        attch.process = false
      )

  # UPLOAD
  $scope.fileReaderSupported = window.FileReader isnt null or (window.FileAPI is null or FileAPI.html5 isnt false)
  # Upload
  $scope.onFileSelect = ($files) ->
    $scope.selectedFiles = []

    $files.forEach( (file, index) ->
      $scope.selectedFiles.push {file: file, index: index, progress: 0, dataUrl: false }
      sel = $scope.selectedFiles[index]

      if $scope.fileReaderSupported and file.type.indexOf('image') > -1
        fileReader = new FileReader()
        fileReader.readAsDataURL(file)

        loadFile = ((fileReader, index) ->
          fileReader.onload = (event) ->
            $timeout(->
              sel.dataUrl = event.target.result
            )
        )(fileReader, index)
    )

    #return #######
    $files.forEach( (file, index) ->

      $scope.upload = $upload.upload(
        url: '/attachments',
        data: {
          attachable_id: $scope.attachable_id,
          attachable_type: $scope.attachable_type,
          position: $scope.position
        },
        file: file
      )
      .progress( (event) ->
        f = $scope.selectedFiles[index]
        f.progress = Math.round((event.loaded / event.total) * 100)
      )
      .success( (data, status, headers, config) ->
        $scope.attachments.push data
      )
      .finally(->
        $scope.selectedFiles[index].terminated = true
      )
    )

# End of function

AttachmentController.$inject = ['$scope', '$http', '$timeout', '$upload']

myApp.controller('AttachmentController', AttachmentController)
