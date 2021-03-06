Rails.application.routes.draw do
  get 'downloader/downloadYoutubeVideo'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'bookmarks/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'bookmarks/domains' => 'bookmarks#domains'
  get 'bookmarks/findByDomain' => 'bookmarks#findByDomain'
  post 'bookmarks/create'
  put  'bookmarks/:id' => 'bookmarks#update', as: 'bookmarks_update'
  put  'bookmarks/:id/addSuffix' => 'bookmarks#addSuffix'
  put  'bookmarks/:id/modulateURL' => 'bookmarks#modulateURL'
  delete 'bookmarks/:id' => 'bookmarks#destroy', as: 'bookmarks_destroy'
  get 'bookmarks/:id' => 'bookmarks#show', as: 'bookmarks_show'
  get 'bookmarks' => 'bookmarks#index', as: 'bookmarks_all'
  get 'bookmarks/:id/getTitle' => 'bookmarks#getTitle'
  get 'bookmarks/:id/getChildren' => 'bookmarks#getChildren'
  get 'mfiles/dl' => 'mfiles#dl'

  get 'bookmarks/:id/fit' => 'bookmarks#fit'

  resources :media

  resources :mfiles do
    get 'download', :on => :member
    get 'generateTn', :on => :member
    get 'fileExistonFS', :on => :member
    get 'tnExistonFS', :on => :member

    post 'add_attri_name', :on => :member
    post 'add_attri', :on => :member
    delete 'remove_attri/:attri_id' => 'mfiles#remove_attri', :on => :member
    post 'add_agroup', :on => :member
    delete 'remove_agroup', :on => :member
    get 'edit0', :on => :member
    get 'new_tag', :on => :member
    get 'update_tag', :on => :member
    get 'delete_tag', :on => :member
    get 'pic', :on => :member
    get 'path', :on => :member
    get 'youtubeLink', :on => :member
    get 'renderMfile', :on => :member
    get  'classify', :on => :collection
    get  'slideshow', :on => :collection
    post 'set_attris', :on => :collection
    get  'thumbs', :on => :collection
    get 'download', :on => :member
  end

  get 'mfiles/folder/:id' => 'mfiles#indexByFolder'
  get 'folders/storage/:id' => 'folders#indexByStorage'
  get 'folders/number' => 'folders#number'
  get 'folders/:id/dir' => 'folders#dir'
  get 'folders/:id/scan' => 'folders#scan'

  get 'folders/:id/enhance' => 'folders#enhance'
  get 'folders/:id/scanAndAddFromOriginLocation' => 'folders#scanAndAddFromOriginLocation'
  put 'folders/:id/moveToLocation' => 'folders#moveToLocation'
  put 'folders/:id/removeMfilesWOPhysicalFile' => 'folders#removeMfilesWOPhysicalFile'

  resources :folders
   resources :locations do
    get 'dir', :on => :member
    post 'addFolder', :on => :member
   end
   resources :fits do
     get 'fit', :on => :collection
     get 'bookmarks', :on => :member
     get 'tworkers', :on => :member
   end

   resources :tworkers do
#     get 'fit', :on => :collection
   end

   get 'tworkers/:id/scanBookmark/:bookmark_id' => 'tworkers#scanBookmark'
   get 'scanner' => 'fits#scanUrl'
   post 'scanner' => 'fits#scanAndSave'
   
   resources :storages do
      get 'downloadable', :on => :member
      get 'locations', :on => :member
      post 'deepCopy', :on => :member
      post 'inheritMtype', :on => :member
      #      put 'newLocation', :on => :member
   end

   resources :attris do
     resources :mfiles
   end

   resources :agroups do
    resources :mfiles
  end

end
