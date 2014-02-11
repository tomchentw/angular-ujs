<a name="0.4.8"></a>
### 0.4.8 (2014-02-11)


#### Bug Fixes

* **bower.json:** update dependencies and devDependencies ([0912c85aa8c962f76f30756c002f6acb490f9304](git://github.com/tomchentw/angular-ujs.git/commit/0912c85aa8c962f76f30756c002f6acb490f9304))


#### Features

* **gulpfile:** adjust for gulp 3.5.0 from tomchentw-boilerplate ([b5d7a69145dc51a29c3cfbb474b4778a8597c21e](git://github.com/tomchentw/angular-ujs.git/commit/b5d7a69145dc51a29c3cfbb474b4778a8597c21e))


<a name="0.4.7"></a>
### 0.4.7 (2014-01-25)


#### Features

* **spec:** add test coverages ([35b186acaed43bd5c4e910ecdace485fe2460ff8](git://github.com/tomchentw/angular-ujs.git/commit/35b186acaed43bd5c4e910ecdace485fe2460ff8))


<a name="0.4.6"></a>
### 0.4.6 (2014-01-17)


#### Bug Fixes

* **gulpfile:** add release-git task with `git push`, `--tags` ([3d965954f04da8826d90dc86755d96c6247412fa](git://github.com/tomchentw/angular-ujs.git/commit/3d965954f04da8826d90dc86755d96c6247412fa))
* **travis:** start rails server in before_script ([c7c178336375419339867fe9cd01ac43e4700d3a](git://github.com/tomchentw/angular-ujs.git/commit/c7c178336375419339867fe9cd01ac43e4700d3a))


<a name="0.4.5"></a>
### 0.4.5 (2014-01-16)


<a name="0.4.4"></a>
### 0.4.4 (2014-01-13)


#### Bug Fixes

* **travis:** start rails server in before_script ([c7c178336375419339867fe9cd01ac43e4700d3a](git://github.com/tomchentw/angular-ujs.git/commit/c7c178336375419339867fe9cd01ac43e4700d3a))


<a name="v0.4.3"></a>
### v0.4.3 (2014-01-04)


#### Bug Fixes

* **CHANGELOG:** should be v0.4.2 ([bf33e9ce](http://github.com/tomchentw/angular-ujs/commit/bf33e9ce1ac1b34ffb2661d96af0c757819fb4a2))

<a name="v0.4.2"></a>
### v0.4.2 (2014-01-04)


#### Bug Fixes

* **confirm:** deny default action only when dismiss confirm ([bcbdd425](http://github.com/tomchentw/angular-ujs/commit/bcbdd42552ea2850693510c48c7df5f9c915b19a))


<a name="0.3.x"></a>
### 0.3.x (2013-12-31)

The changelog before `v0.4.0` are collapsed into one.

#### Bug Fixes

* **Gruntfile:** add shell prefix ([73f2381c3316a826d33720f0d00be26a70ae5506](git://github.com/tomchentw/angular-ujs.git/commit/73f2381c3316a826d33720f0d00be26a70ae5506))
* **confirm:**
  * directive should inject RailsConfirmCtrl ([bfe2571afbda23189fa10a59ab7032a75774c22f](git://github.com/tomchentw/angular-ujs.git/commit/bfe2571afbda23189fa10a59ab7032a75774c22f))
  * fix confirm logic and add confirm directive ([903edd646c41d4faf639d9f790516e02ca46febd](git://github.com/tomchentw/angular-ujs.git/commit/903edd646c41d4faf639d9f790516e02ca46febd))
* **directive:** fix compile return noop, change to void ([3d31a30474a683f436f88e0df6032d7afa55819a](git://github.com/tomchentw/angular-ujs.git/commit/3d31a30474a683f436f88e0df6032d7afa55819a))
* **rails:**
  * createMethodFormElement will use $apply ([77d8c416bdb3a33a071c075147352a84cb74ff3c](git://github.com/tomchentw/angular-ujs.git/commit/77d8c416bdb3a33a071c075147352a84cb74ff3c))
  * remove jQuery method ([1c2f004c43321a97eca5f0381df1a83d67d21608](git://github.com/tomchentw/angular-ujs.git/commit/1c2f004c43321a97eca5f0381df1a83d67d21608))
* **remote:** rails 4 http method overriding issue and make them work together ([ed00160862635e985b1b56ce798ee4e402994e0b](git://github.com/tomchentw/angular-ujs.git/commit/ed00160862635e985b1b56ce798ee4e402994e0b))
* **travis:** run db:migrate before start server ([c19387daaea1e101bb4a640fe533dcd13d648e86](git://github.com/tomchentw/angular-ujs.git/commit/c19387daaea1e101bb4a640fe533dcd13d648e86))


#### Features

* **$getRailsCSRF:** add conditional service ([bc39820863b63e93eff1f200ef44c70d8c08ca00](git://github.com/tomchentw/angular-ujs.git/commit/bc39820863b63e93eff1f200ef44c70d8c08ca00))
* **controller:** add RailsRemoteFormCtrl ([fa71046595028dc39a21f0df9e96caa3354bb137](git://github.com/tomchentw/angular-ujs.git/commit/fa71046595028dc39a21f0df9e96caa3354bb137))
* **directive:**
  * remote directive will evaluation on $scope if data-remote is true ([041c8f64a245651a002554321c236a31a28c9374](git://github.com/tomchentw/angular-ujs.git/commit/041c8f64a245651a002554321c236a31a28c9374))
  * add method directive and work with remote directive ([fa05cc5889e88a9391d2769c7bd1f4462d6f6d4c](git://github.com/tomchentw/angular-ujs.git/commit/fa05cc5889e88a9391d2769c7bd1f4462d6f6d4c))
  * add remote directive ([1e5166679f81db4b0e3442a3c1eb035cb0cb5b85](git://github.com/tomchentw/angular-ujs.git/commit/1e5166679f81db4b0e3442a3c1eb035cb0cb5b85))
* **karma:** add karma and jasmine as test framework, remove .min.js in vender ([73c1601ba45f8aca2933f6c39b8ff7340778f880](git://github.com/tomchentw/angular-ujs.git/commit/73c1601ba45f8aca2933f6c39b8ff7340778f880))
* **noopRailsConfirmCtrl:** extract to controller ([a4ec390443e3eee0c463f198a65422a3b4c4befb](git://github.com/tomchentw/angular-ujs.git/commit/a4ec390443e3eee0c463f198a65422a3b4c4befb))
* **noopRailsRemoteFormCtrl:** extract to controller ([90189f77e2c57a57fd2d26aa844f8dc32cd08d24](git://github.com/tomchentw/angular-ujs.git/commit/90189f77e2c57a57fd2d26aa844f8dc32cd08d24))
* **rails:**
  * remove rails service ([6a7d3adaaa91f99f6d68797289589e6c4ded4109](git://github.com/tomchentw/angular-ujs.git/commit/6a7d3adaaa91f99f6d68797289589e6c4ded4109))
  * prepare to remove rails service ([f996915cdf083bedaeada6de696c83ef44249cac](git://github.com/tomchentw/angular-ujs.git/commit/f996915cdf083bedaeada6de696c83ef44249cac))
  * noopRemoteFormCtrl will call form.submit ([aab27adf1b39f4deed50bdd5729aefc31bc60167](git://github.com/tomchentw/angular-ujs.git/commit/aab27adf1b39f4deed50bdd5729aefc31bc60167))
  * add getMetaTags, createMethodFormElement ([6d027180432b752de13a941adcd7cd1987dc699f](git://github.com/tomchentw/angular-ujs.git/commit/6d027180432b752de13a941adcd7cd1987dc699f))
  * add noopRemoteFormCtrl as null object ([0c75bd051f932e63326e804a9156a05a8287c285](git://github.com/tomchentw/angular-ujs.git/commit/0c75bd051f932e63326e804a9156a05a8287c285))
  * add rails service as factory, add rails.confirmAction ([58c4d858a745dd7d3c75e377a5f714ac3135ab84](git://github.com/tomchentw/angular-ujs.git/commit/58c4d858a745dd7d3c75e377a5f714ac3135ab84))
* **scenario:** setup protractor as e2e framework ([cdb982f0a529b8fa40b82111e6777a8cda7b4bd7](git://github.com/tomchentw/angular-ujs.git/commit/cdb982f0a529b8fa40b82111e6777a8cda7b4bd7))
* **test:** setup TDD ([f09f5a773cbb9bd3da68b9deb6dba23911aeea58](git://github.com/tomchentw/angular-ujs.git/commit/f09f5a773cbb9bd3da68b9deb6dba23911aeea58))
* **travis:** add travis ci support ([7adfbfc7aab5969d2c8572ce1aa8d97a2dce96e3](git://github.com/tomchentw/angular-ujs.git/commit/7adfbfc7aab5969d2c8572ce1aa8d97a2dce96e3))


