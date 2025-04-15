# CHANGELOG

## [6.40.1](https://gitlab.com/carcheky/raspiserver/compare/v6.40.0...v6.40.1) (2025-04-12)


### Bug Fixes

* **docker-compose:** increase CPU limit for homarr service to 0.80 ([82383a6](https://gitlab.com/carcheky/raspiserver/commit/82383a62c3e6a81a31d151645b409a49974ffd37))

# [6.40.0](https://gitlab.com/carcheky/raspiserver/compare/v6.39.0...v6.40.0) (2025-04-01)


### Bug Fixes

* habilitar modo de red para cosmos y comentar puertos ([406276d](https://gitlab.com/carcheky/raspiserver/commit/406276d8790b492032782f1f52e88ff81b8f39e3))


### Features

* cosmos-server ([140b5f4](https://gitlab.com/carcheky/raspiserver/commit/140b5f49158b7237ad25f3dae78e3b7bf3823cf5))
* **dockge:** add docker-compose configuration for dockge service ([f4a8500](https://gitlab.com/carcheky/raspiserver/commit/f4a8500e904e6578fa36a9d2661ad66411b10c5a))
* **dockge:** enable console in docker-compose configuration ([42d9f5a](https://gitlab.com/carcheky/raspiserver/commit/42d9f5afd50dc745be2584b9fa3a3fed0600212a))

# [6.39.0](https://gitlab.com/carcheky/raspiserver/compare/v6.38.0...v6.39.0) (2025-03-30)


### Bug Fixes

* actualizar configuración de puertos en docker-compose para AdGuard Home ([772a0fc](https://gitlab.com/carcheky/raspiserver/commit/772a0fc4f9a6acc490950a377a3d2afa24fab608))
* actualizar configuración de volúmenes en docker-compose.nextcloud.yml ([5783652](https://gitlab.com/carcheky/raspiserver/commit/5783652563f21e4fbb2eda13a48398108f9196a8))
* agregar configuración de Nginx Proxy Manager en docker-compose ([6ac0a53](https://gitlab.com/carcheky/raspiserver/commit/6ac0a53b05f68763bcb8325b8950630193aabc09))
* cambiar el puerto de la aplicación de 3000 a 3002 en docker-compose ([a93da04](https://gitlab.com/carcheky/raspiserver/commit/a93da040d94dd6b216b9c8e5765cd3512f6516f1))
* corregir formato de inclusión de plantillas en .gitlab-ci.yml ([7812455](https://gitlab.com/carcheky/raspiserver/commit/781245552f174c8746e8d1e9f5151b94f21fc208))
* corregir sangrado en la sección de SAST en .gitlab-ci.yml ([9389124](https://gitlab.com/carcheky/raspiserver/commit/9389124ba823ac773b10acbf6bfc81ee6aaa6a38))
* deshabilitar ejecución del trabajo de sincronización en la rama estable en .gitlab-ci.yml ([3c58812](https://gitlab.com/carcheky/raspiserver/commit/3c58812ab1889f4c7890ea71ba4a42406900c032))
* reemplazar configuración de Nginx en docker-compose al moverla a la carpeta de proxy ([5fd5732](https://gitlab.com/carcheky/raspiserver/commit/5fd57327e2f0e70e2ff0c62bc4ab5deaa53c0e30))
* renombrar servicio de nginx a proxy y ajustar puertos en docker-compose ([ba22def](https://gitlab.com/carcheky/raspiserver/commit/ba22def208e03ad63f84284528d4236373e38a3d))


### Features

* agregar configuración de NordVPN y archivos relacionados en docker-compose ([a17d91f](https://gitlab.com/carcheky/raspiserver/commit/a17d91fa3ca4e4174a000fce1c5a76b69b3481bf))
* agregar configuración de Pi-hole en docker-compose ([4795163](https://gitlab.com/carcheky/raspiserver/commit/4795163427a6ab4855ea1112087fa1ede5ab378b))
* agregar etapa de sincronización de la rama beta con la rama estable en .gitlab-ci.yml ([7fc7aea](https://gitlab.com/carcheky/raspiserver/commit/7fc7aea61f17cfa71907e4127cf9dbb9f62fbd9f))
* **nextcloud:** agregar configuración de docker-compose para el servicio nextcloud-appapi-dsp ([4a9736f](https://gitlab.com/carcheky/raspiserver/commit/4a9736f3eb52913be4318b42b0cb2de12764ec93))
* **nextcloud:** agregar configuración de docker-compose para el servicio nextcloud-appapi-dsp y nueva variable de entorno NC_HAPROXY_PASSWORD ([4e8c386](https://gitlab.com/carcheky/raspiserver/commit/4e8c386c94fbfa76d9fd5218a30f82a8c9bb8c95))
* **nextcloud:** agregar script de instalación para NordVPN en múltiples gestores de paquetes ([4061a29](https://gitlab.com/carcheky/raspiserver/commit/4061a29e2005b765bdf96a34961e277ff9dc80bd))

# [6.38.0](https://gitlab.com/carcheky/raspiserver/compare/v6.37.0...v6.38.0) (2025-03-09)


### Features

* agregar configuración de Docker para Soulseek ([3c9fd4e](https://gitlab.com/carcheky/raspiserver/commit/3c9fd4e2af55c7c529b9f46a6c7404aa38a5ceaf))

# [6.37.0](https://gitlab.com/carcheky/raspiserver/compare/v6.36.0...v6.37.0) (2025-02-25)


### Features

* added uptime-kener ([49197fd](https://gitlab.com/carcheky/raspiserver/commit/49197fd85d4ca623a6e56ad7af3eeae218193177))

# [6.36.0](https://gitlab.com/carcheky/raspiserver/compare/v6.35.0...v6.36.0) (2025-02-24)


### Features

* add docker-compose configuration for uptime-kuma service ([4d1ef6e](https://gitlab.com/carcheky/raspiserver/commit/4d1ef6eaa1a372e133a0786259358ec2ba284b88))

# [6.35.0](https://gitlab.com/carcheky/raspiserver/compare/v6.34.0...v6.35.0) (2025-02-18)


### Bug Fixes

* language overlay ([397595b](https://gitlab.com/carcheky/raspiserver/commit/397595b13a08c31568fce33162550c0679d412eb))
* **nextcloud:** generic port ([a3caf11](https://gitlab.com/carcheky/raspiserver/commit/a3caf114ffefa11f560f4e1d596f827816d51b51))
* posters with langs ([990289d](https://gitlab.com/carcheky/raspiserver/commit/990289dd415660b02e7b89bde0c06462d714ecee))


### Features

* add lang to images ([e1f7449](https://gitlab.com/carcheky/raspiserver/commit/e1f7449e76f81cd137ab11f0e14d2bdf7b570228))

# [6.34.0](https://gitlab.com/carcheky/raspiserver/compare/v6.33.0...v6.34.0) (2024-12-31)


### Bug Fixes

* configs ([308145a](https://gitlab.com/carcheky/raspiserver/commit/308145a07580edd648a9480afe28e6a7b433214c))


### Features

* all trailers ([fc433c3](https://gitlab.com/carcheky/raspiserver/commit/fc433c33c9b8f8c42151a4057a6ba548af5168ee))

# [6.33.0](https://gitlab.com/carcheky/raspiserver/compare/v6.32.0...v6.33.0) (2024-12-05)


### Bug Fixes

* added bthelper ([32a95ed](https://gitlab.com/carcheky/raspiserver/commit/32a95edf45548eecf2b1cf75974c9ed50c8913b5))
* configs ([877fab1](https://gitlab.com/carcheky/raspiserver/commit/877fab1bad909498de882ba2b7a62ad6619464f5))
* configs ([f80ec83](https://gitlab.com/carcheky/raspiserver/commit/f80ec835c3715f1e89d0029c0630ce8997877c1e))
* configs ([e6a2d91](https://gitlab.com/carcheky/raspiserver/commit/e6a2d91a8dcafff2509b664b3a91d0e61d668d57))


### Features

* added esphome ([72377b1](https://gitlab.com/carcheky/raspiserver/commit/72377b157aef11c31412220c49ff22035c54cb0c))
* bthelper.sh ([1b2d6b0](https://gitlab.com/carcheky/raspiserver/commit/1b2d6b05746c76a77f1b893b28ddbb28d9501181))

# [6.32.0](https://gitlab.com/carcheky/raspiserver/compare/v6.31.0...v6.32.0) (2024-11-26)


### Bug Fixes

* configs ([747376d](https://gitlab.com/carcheky/raspiserver/commit/747376d624634b29ce3735e7ef09006267a69bcf))
* configs ([aaf1967](https://gitlab.com/carcheky/raspiserver/commit/aaf196712f3eb0ed17850ce9375cbe420cc26e8b))
* configs ([61ff2c8](https://gitlab.com/carcheky/raspiserver/commit/61ff2c8311ef61b5c56bd472ae6733c6bcfc1806))
* disable services ([efdae77](https://gitlab.com/carcheky/raspiserver/commit/efdae779f279f30f4be0d295d099b05b5306649d))
* tdarr ([83552eb](https://gitlab.com/carcheky/raspiserver/commit/83552eba037ea64995229835acb71f6479892703))


### Features

* arr scripts included ([98e6d27](https://gitlab.com/carcheky/raspiserver/commit/98e6d27a6cf5bcb53b318454b14b781465c0f6fc))
* tdarr ([efe1382](https://gitlab.com/carcheky/raspiserver/commit/efe138275dc6596d800a0ef080f22fadb644a91e))

# [6.31.0](https://gitlab.com/carcheky/raspiserver/compare/v6.30.0...v6.31.0) (2024-11-07)


### Bug Fixes

* intros in library ([35b29d2](https://gitlab.com/carcheky/raspiserver/commit/35b29d2618eb2c65a3619c86f6d19f80111d955c))


### Features

* code server ([ac04f9d](https://gitlab.com/carcheky/raspiserver/commit/ac04f9d3482fd2ad84d426e6f08e46155295624b))

# [6.30.0](https://gitlab.com/carcheky/raspiserver/compare/v6.29.2...v6.30.0) (2024-10-24)


### Bug Fixes

* restore linuxserver containers ([350d81a](https://gitlab.com/carcheky/raspiserver/commit/350d81a49979f3f421bcc9ed83053973c77fb988))


### Features

* added sonarr scripts ([1b21f07](https://gitlab.com/carcheky/raspiserver/commit/1b21f07a5dbedec225ccfef2baf2b928ce45ffdf))

## [6.29.2](https://gitlab.com/carcheky/raspiserver/compare/v6.29.1...v6.29.2) (2024-10-22)


### Bug Fixes

* performance ([a4a18d0](https://gitlab.com/carcheky/raspiserver/commit/a4a18d08aba65647d468d0649bbe0196a00253d5))
* performance ([8a5b65f](https://gitlab.com/carcheky/raspiserver/commit/8a5b65f942ba0df517ab3791227fa1a95a650bcb))

## [6.29.1](https://gitlab.com/carcheky/raspiserver/compare/v6.29.0...v6.29.1) (2024-10-20)


### Bug Fixes

* configs ([b4cd217](https://gitlab.com/carcheky/raspiserver/commit/b4cd21732c6cb82167bc7709e3af3058579edfd1))
* limit resources ([64eb671](https://gitlab.com/carcheky/raspiserver/commit/64eb671f6bb502287902a39b7acd3e44a2ff4aaa))
* limit resources ([9bbb26d](https://gitlab.com/carcheky/raspiserver/commit/9bbb26da4689f1bbdbacd154c10e1ee2f3f5ee57))
* performance ([5e2592a](https://gitlab.com/carcheky/raspiserver/commit/5e2592a238378bb1eb1960e0035327310a965fef))

# [6.29.0](https://gitlab.com/carcheky/raspiserver/compare/v6.28.0...v6.29.0) (2024-10-18)


### Bug Fixes

* configs ([ff88a06](https://gitlab.com/carcheky/raspiserver/commit/ff88a06ab47db37826051cd1211a9feb4311360f))
* configs ([e7ee3bf](https://gitlab.com/carcheky/raspiserver/commit/e7ee3bf3d8d6a07a190ce3831d6331fe723d94fb))
* configs ([b697f69](https://gitlab.com/carcheky/raspiserver/commit/b697f6963931adf39cb9762ded6fccdaa628dd41))
* configs ([abe05a5](https://gitlab.com/carcheky/raspiserver/commit/abe05a5e198e40f5b64468e002c97c9a26537b96))
* configure watchtower ([0e496a7](https://gitlab.com/carcheky/raspiserver/commit/0e496a76bebfa23658658d6a3f512dcaca26a957))


### Features

* radar get extras ([29ac841](https://gitlab.com/carcheky/raspiserver/commit/29ac8418faa6df021be499bad5fe43037657ae06))
* watchtower ([74fbb34](https://gitlab.com/carcheky/raspiserver/commit/74fbb34b9ec4b3abf878c0b44965e2120e7c1146))

# [6.28.0](https://gitlab.com/carcheky/raspiserver/compare/v6.27.0...v6.28.0) (2024-10-16)


### Bug Fixes

* configs ([0b9c599](https://gitlab.com/carcheky/raspiserver/commit/0b9c599a1cb6e15da4cd6afaa034944b55ea953c))
* configs ([53fb8ca](https://gitlab.com/carcheky/raspiserver/commit/53fb8ca11957101b1e87ed8e565ef7d29b944fa3))
* **romassistant:** added container name ([eac0a16](https://gitlab.com/carcheky/raspiserver/commit/eac0a16fec3567d22cc451172219c4abc30ef3e4))


### Features

* enable memories ([5f213db](https://gitlab.com/carcheky/raspiserver/commit/5f213db6579069ab90978f001a973db0ab0581ba))
* lidarr & readarr ([73f39b8](https://gitlab.com/carcheky/raspiserver/commit/73f39b8f4462bb68bfb849feb975ffcd1f6428b2))
* room-assistant ([a30b108](https://gitlab.com/carcheky/raspiserver/commit/a30b1080e7e3f1b726011aec8855cf663a88b2d0))

# [6.27.0](https://gitlab.com/carcheky/raspiserver/compare/v6.26.1...v6.27.0) (2024-09-20)


### Bug Fixes

* configs ([78986ae](https://gitlab.com/carcheky/raspiserver/commit/78986aee604b592b649978c4531c70ac8e79f269))
* configs ([5883ce4](https://gitlab.com/carcheky/raspiserver/commit/5883ce4ab76340ad1767e10fa772ba935fc40d37))
* configs ([d3f2de5](https://gitlab.com/carcheky/raspiserver/commit/d3f2de578aaeb90db6fbecc20d83f2f142635f42))
* disable memories ([581008a](https://gitlab.com/carcheky/raspiserver/commit/581008a67cc531bc7d38550d05cbd0098915ff9d))
* **jellyfin:** encoding ([7262a38](https://gitlab.com/carcheky/raspiserver/commit/7262a3834510a8e528c4a57a6c4c76d914b4fbe4))
* update all ([e611b60](https://gitlab.com/carcheky/raspiserver/commit/e611b6018dd06ebfca9ef338974a9a8bc0e7a111))


### Features

* **radarr:** disable custom scripts ([ca092c6](https://gitlab.com/carcheky/raspiserver/commit/ca092c64b9d57ed2aba3d337d7925b041f9a5feb))
* replace transmission with qbittorrent ([def572c](https://gitlab.com/carcheky/raspiserver/commit/def572c91ccbb4ebc4279e7354d3cabfa2f38814))

## [6.26.1](https://gitlab.com/carcheky/raspiserver/compare/v6.26.0...v6.26.1) (2024-08-13)


### Bug Fixes

* configs ([f831ff6](https://gitlab.com/carcheky/raspiserver/commit/f831ff6440aaae2ce31095251e8daa6ee0f45620))
* configs ([b90aa9c](https://gitlab.com/carcheky/raspiserver/commit/b90aa9ca5a389cdc60d6a8619b3dba8fb258ddfc))
* configs ([8c4ed20](https://gitlab.com/carcheky/raspiserver/commit/8c4ed206d935aca573237b2578da61f4351011cd))
* configs ([33c6828](https://gitlab.com/carcheky/raspiserver/commit/33c68286da52c4c12b768ad0bd50079811221dff))
* configs ([416a8cf](https://gitlab.com/carcheky/raspiserver/commit/416a8cff78a9a6ac5e565e4592fcab497e1b5b4d))
* configs ([d331361](https://gitlab.com/carcheky/raspiserver/commit/d3313614f7a085a76de16b8ab55b00967857b484))
* lock transmission version ([76b610d](https://gitlab.com/carcheky/raspiserver/commit/76b610da23d3db6d3c2f867370702b8e76f3b402))
* mediacheky ([461b065](https://gitlab.com/carcheky/raspiserver/commit/461b06537b555f9ae1dbaa3694a407b5268c440c))
* **nextcloud:** network drive ([2a81187](https://gitlab.com/carcheky/raspiserver/commit/2a811874f1fc04b5de848583c7a08872fe654d1b))

# [6.26.0](https://gitlab.com/carcheky/raspiserver/compare/v6.25.2...v6.26.0) (2024-07-27)


### Bug Fixes

* configs ([d5ffbf5](https://gitlab.com/carcheky/raspiserver/commit/d5ffbf5cf628c7610fb51eddca4929005558493a))
* configs ([0b6b16e](https://gitlab.com/carcheky/raspiserver/commit/0b6b16eefc1cb240dad32404cef40b1a58831021))
* configs ([c4e18be](https://gitlab.com/carcheky/raspiserver/commit/c4e18be4b49779931bd4a377086df56437e271fd))
* configs ([4616420](https://gitlab.com/carcheky/raspiserver/commit/461642042f401102c6f108e383a977f585f2ebb3))
* configs ([13409fc](https://gitlab.com/carcheky/raspiserver/commit/13409fc158d64d7eb94a6a7cc0b41f300d74279b))
* configs ([796922a](https://gitlab.com/carcheky/raspiserver/commit/796922a5bdbe89aa495f86b2f9ed2e407d66635e))
* **janitorr:** fix version ([10991ab](https://gitlab.com/carcheky/raspiserver/commit/10991abbebe922d220c68d4e18ae39e533a64284))
* **jellyfin:** encoding settings ([28378d0](https://gitlab.com/carcheky/raspiserver/commit/28378d080a784a64822856580612d9c6c3267b57))
* **jellyfin:** fixed encoding ([a53e7fa](https://gitlab.com/carcheky/raspiserver/commit/a53e7fae095ca0670c4981bace7b20a90e4ad15d))
* **nextcloud:** remove duplicate volume ([ae474de](https://gitlab.com/carcheky/raspiserver/commit/ae474ded3b14d2e9cecee18dd20891fbbada8ced))
* **qbitorrent:** connected ([3db2623](https://gitlab.com/carcheky/raspiserver/commit/3db262378d1ac1719591e98a870ed31b5b3a6ac3))


### Features

* **homarr:** docker support ([26716a7](https://gitlab.com/carcheky/raspiserver/commit/26716a74909a1e555d532a775299cf47db676c16))
* janitorr ([dc63be7](https://gitlab.com/carcheky/raspiserver/commit/dc63be78437f6d22ceff1ee2301e7d88fc7d3190))
* jellystats ([1b41cc3](https://gitlab.com/carcheky/raspiserver/commit/1b41cc321203e3d34f3a63f33e25443343c1639a))
* nextcloud ([30ff096](https://gitlab.com/carcheky/raspiserver/commit/30ff096a16f029d6b67982245542c8fbc211467c))
* wireward ([49988eb](https://gitlab.com/carcheky/raspiserver/commit/49988eb1221b046764531666dd5873c7f6583110))

## [6.25.2](https://gitlab.com/carcheky/raspiserver/compare/v6.25.1...v6.25.2) (2024-05-11)


### Bug Fixes

* backup on update ([6ec5c24](https://gitlab.com/carcheky/raspiserver/commit/6ec5c2458f137919175abff5e46d5ca9e6bbcea6))
* backup script ([b8f0638](https://gitlab.com/carcheky/raspiserver/commit/b8f0638962884fd93a97875dc98275f1bcafed14))
* configs ([88dfa01](https://gitlab.com/carcheky/raspiserver/commit/88dfa0192b17ce75cf62e0709d4c9b9f38f66734))
* configs ([423f738](https://gitlab.com/carcheky/raspiserver/commit/423f7384ef9c02c279fd8d7f642c4486b677bdf0))
* **mediacheky:** fix user ([2559ef6](https://gitlab.com/carcheky/raspiserver/commit/2559ef60fff9976135aab289dfc22703ac708dab))

## [6.25.1](https://gitlab.com/carcheky/raspiserver/compare/v6.25.0...v6.25.1) (2024-04-23)


### Bug Fixes

* gitignore ([fc4e046](https://gitlab.com/carcheky/raspiserver/commit/fc4e04641da6ad5c1eff435f3df6fcd970acd462))

# [6.25.0](https://gitlab.com/carcheky/raspiserver/compare/v6.24.2...v6.25.0) (2024-04-19)


### Features

* added nginx-proxy-manager ([34d1d53](https://gitlab.com/carcheky/raspiserver/commit/34d1d53e6ec774132b72ee3ce142b99944918903))

## [6.24.2](https://gitlab.com/carcheky/raspiserver/compare/v6.24.1...v6.24.2) (2024-04-02)


### Bug Fixes

* adguard rework ([2585dab](https://gitlab.com/carcheky/raspiserver/commit/2585dab54001f51a6b5f405750af3e559c4257c3))

## [6.24.1](https://gitlab.com/carcheky/raspiserver/compare/v6.24.0...v6.24.1) (2024-03-22)


### Bug Fixes

* **mediaserver:** use ports ([31864c3](https://gitlab.com/carcheky/raspiserver/commit/31864c37b9e60e6d64884cef4a1c7d3fc21950ea))

# [6.24.0](https://gitlab.com/carcheky/raspiserver/compare/v6.23.0...v6.24.0) (2024-03-19)


### Bug Fixes

* **homeassistant:** config dirs ([9c3947c](https://gitlab.com/carcheky/raspiserver/commit/9c3947c70f304008e2b1aed062e61be6ed1b2c94))
* jellyfin group id ([8999bfb](https://gitlab.com/carcheky/raspiserver/commit/8999bfb7047908f8a99a2d1b18696c1cca73701d))
* **test:** empty commit ([06eae95](https://gitlab.com/carcheky/raspiserver/commit/06eae954da4b84ff93772722df7f3c79ccbc7d2c))


### Features

* **mediaserver:** rework ([7314d52](https://gitlab.com/carcheky/raspiserver/commit/7314d5258b0ffd045a9eab373c8bf165f8f851e5))
* rework ([8d61085](https://gitlab.com/carcheky/raspiserver/commit/8d61085fd0b8121bdce50bc9e6d3440f084a2b84))
* **tunnel:** reworked ([6c002ec](https://gitlab.com/carcheky/raspiserver/commit/6c002ec1bd0f8c1fac6704d6c08558316687a781))

# [6.23.0](https://gitlab.com/carcheky/raspiserver/compare/v6.22.2...v6.23.0) (2024-03-19)


### Bug Fixes

* **homeassistant:** config dirs ([9c3947c](https://gitlab.com/carcheky/raspiserver/commit/9c3947c70f304008e2b1aed062e61be6ed1b2c94))
* pihole ([31b1705](https://gitlab.com/carcheky/raspiserver/commit/31b1705491afb2bb2aadb9233789d2ea1eeb8d5e))


### Features

* **mediaserver:** rework ([7314d52](https://gitlab.com/carcheky/raspiserver/commit/7314d5258b0ffd045a9eab373c8bf165f8f851e5))
* nextcloud ([0107885](https://gitlab.com/carcheky/raspiserver/commit/010788508c582a0fac915dc0b4dacd872d911644))
* rework ([8d61085](https://gitlab.com/carcheky/raspiserver/commit/8d61085fd0b8121bdce50bc9e6d3440f084a2b84))
* nextcloud ([0107885](https://gitlab.com/carcheky/raspiserver/commit/010788508c582a0fac915dc0b4dacd872d911644))

## [6.22.2](https://gitlab.com/carcheky/raspiserver/compare/v6.22.1...v6.22.2) (2024-03-14)


### Bug Fixes

* mediacheky update ([b54d7b9](https://gitlab.com/carcheky/raspiserver/commit/b54d7b953c8ead8b65e6191c6c6e99c223df4241))

## [6.22.1](https://gitlab.com/carcheky/raspiserver/compare/v6.22.0...v6.22.1) (2024-03-09)


### Bug Fixes

* gitignore ([c1186e2](https://gitlab.com/carcheky/raspiserver/commit/c1186e283fa7575086180e5b4ba4ec7f85439796))
* local detect ([bbdf28f](https://gitlab.com/carcheky/raspiserver/commit/bbdf28f3dab54df6d52653698a70e5bed82c7865))

# [6.22.0](https://gitlab.com/carcheky/raspiserver/compare/v6.21.1...v6.22.0) (2024-03-07)


### Bug Fixes

* devices ([acce232](https://gitlab.com/carcheky/raspiserver/commit/acce2323b0a59e9f36ac222088c9301e21158df1))
* **emby:** path ([f3c5a7c](https://gitlab.com/carcheky/raspiserver/commit/f3c5a7cf5c740c48507dcba3f60dd69399bc0ae9))
* **emby:** remove runtime ([ddcc8e5](https://gitlab.com/carcheky/raspiserver/commit/ddcc8e561272d616f68f78d61c9b6da5164bc146))
* host ([f083f5d](https://gitlab.com/carcheky/raspiserver/commit/f083f5d379a51d528c1cca6d260317338d2e46d4))
* network ([630a1df](https://gitlab.com/carcheky/raspiserver/commit/630a1df88c0ab944c0d3ecadc9feb963d7de1fd6))
* plex vars ([4696bdd](https://gitlab.com/carcheky/raspiserver/commit/4696bdd66f6723e93214b8312b45351f81f141f7))
* **plex:** restart always ([36c7e82](https://gitlab.com/carcheky/raspiserver/commit/36c7e820137bf71da808fe67b7e4af7d121ae76d))
* var ([e995cc5](https://gitlab.com/carcheky/raspiserver/commit/e995cc5022f101b9c22e9d34666a95e10a626960))


### Features

* activepieces ([237fd06](https://gitlab.com/carcheky/raspiserver/commit/237fd06eb40809fe1c8debede4e6ea3f394fba26))
* added n8n ([f5b1d40](https://gitlab.com/carcheky/raspiserver/commit/f5b1d40f6795077ef16fe6cb8595bfb1ea47a671))
* cloudflare tunnel ([1b49d03](https://gitlab.com/carcheky/raspiserver/commit/1b49d03a8f73270f373f7ba319a15f0ce7e235fa))
* emby ([1444dbe](https://gitlab.com/carcheky/raspiserver/commit/1444dbefde1a11d6aa4c64702e754dd49fdd1144))
* emby ([6580c7c](https://gitlab.com/carcheky/raspiserver/commit/6580c7c89dd5c815d68f8bf344c0f1ceb3b2dd63))
* plex ([92257ab](https://gitlab.com/carcheky/raspiserver/commit/92257ab84c025f75b86aaafcee58ed406995e191))

## [6.21.1](https://gitlab.com/carcheky/raspiserver/compare/v6.21.0...v6.21.1) (2024-02-23)


### Bug Fixes

* dashboard ([60b4e18](https://gitlab.com/carcheky/raspiserver/commit/60b4e18678e64ef0ae3917978d6aeef6e39e6d39))

# [6.21.0](https://gitlab.com/carcheky/raspiserver/compare/v6.20.1...v6.21.0) (2024-02-01)


### Bug Fixes

* crontab ([1578c4d](https://gitlab.com/carcheky/raspiserver/commit/1578c4db1e5ead6c243454f6b0683c754bf98e6d))
* fstab config ([3e5f098](https://gitlab.com/carcheky/raspiserver/commit/3e5f098a4e3b95f9ba7dba7fed9fdb4fb8474481))
* mediacheky script ([0c1243d](https://gitlab.com/carcheky/raspiserver/commit/0c1243db4ab6b969deb81d18d7bce9e739e7bf32))
* mediacheky script ([d4edb43](https://gitlab.com/carcheky/raspiserver/commit/d4edb43bcc879798792b30f0e2ddd45f3279bb43))
* mediacheky script ([82bf9c8](https://gitlab.com/carcheky/raspiserver/commit/82bf9c86ddff03543706351f075ba87f3bed1086))
* portainer ([173edd6](https://gitlab.com/carcheky/raspiserver/commit/173edd640b877507d4185d9c5e49b814daaa2fb2))


### Features

* portainer ([9afcfac](https://gitlab.com/carcheky/raspiserver/commit/9afcfac02fb7181b172d5e0a3fb0bf30c60623f4))

## [6.20.1](https://gitlab.com/carcheky/raspiserver/compare/v6.20.0...v6.20.1) (2024-01-29)


### Bug Fixes

* added .kopiaignore ([1c637a6](https://gitlab.com/carcheky/raspiserver/commit/1c637a68b69d2ce98949b4a4181f979aac821463))
* backups ([3a6dec2](https://gitlab.com/carcheky/raspiserver/commit/3a6dec2584f0813b53fec86b7c9f82a302c9a052))
* configs ([4fce5af](https://gitlab.com/carcheky/raspiserver/commit/4fce5af594106f84f825caee177fef479e9572ef))
* cron ([85ec068](https://gitlab.com/carcheky/raspiserver/commit/85ec0688d49843ccba3cce3599d6d861fd46d4c3))
* **cron:** daily update ([267b973](https://gitlab.com/carcheky/raspiserver/commit/267b973cfbca5314f2922a3a903670dd5a5cc8a1))
* **docker:** split dashboard ([130f60b](https://gitlab.com/carcheky/raspiserver/commit/130f60bd8522212f7fb51ab5df164474c57f055d))
* edited .kopiaignore ([5576e27](https://gitlab.com/carcheky/raspiserver/commit/5576e271a2266e95dfee620016971a5cfe03b049))
* edited .kopiaignore ([19c25a2](https://gitlab.com/carcheky/raspiserver/commit/19c25a2a73f65ae1b034beb139f4639eb33a6000))
* hourly mediacheky update ([d1bd1e1](https://gitlab.com/carcheky/raspiserver/commit/d1bd1e1e3ffa90c35e55c5860d2b4dd53dce0fba))
* info ([6a1dfdb](https://gitlab.com/carcheky/raspiserver/commit/6a1dfdbd2108133045c41772c4cda125fbab45e1))
* list hard disks ([992ddaa](https://gitlab.com/carcheky/raspiserver/commit/992ddaa2b357242831308900b34fd525de4964a8))
* logs folder ([7e6327f](https://gitlab.com/carcheky/raspiserver/commit/7e6327fc0a5fc0b864e7ed85cf72b71b4af02d4a))
* mediacheky update ([33c9823](https://gitlab.com/carcheky/raspiserver/commit/33c98233ce6b8a18a22ce2f30b640fc475046592))
* **mediacheky update_all:** now run 2 times/server ([e35fd5b](https://gitlab.com/carcheky/raspiserver/commit/e35fd5bd870209165a2378c119c87ef88f41e574))
* **mediacheky update:** now apt update log is hidden ([d12fd15](https://gitlab.com/carcheky/raspiserver/commit/d12fd150a24804b7025d54235d3bc309df9f304f))
* **mediacheky update:** quiet pull ([9af83d5](https://gitlab.com/carcheky/raspiserver/commit/9af83d5a39419416f0939c0376e179cfb89ecc2a))
* **mediacheky update:** sudo mount -a only in larkcheky ([241df0a](https://gitlab.com/carcheky/raspiserver/commit/241df0ab53c9ea8edb33cc77f483dbd5f7aad13f))
* **mediacheky update:** update shelf first ([7e57962](https://gitlab.com/carcheky/raspiserver/commit/7e57962dd3beb9fdab5a7fc950bf55a720d2359c))
* pull always ([56d219e](https://gitlab.com/carcheky/raspiserver/commit/56d219ea687d7f89bee4947cae10cade503f20c4))
* script separator ([a2ee747](https://gitlab.com/carcheky/raspiserver/commit/a2ee7477e38e23cbd2bfb56f678b7c0c740b7ce1))
* secure updates ([7a67b3a](https://gitlab.com/carcheky/raspiserver/commit/7a67b3a7d9873aea31d8b7620fe99c9d55343e75))
* show raid info on update ([48424fe](https://gitlab.com/carcheky/raspiserver/commit/48424fee66d3bfb485e825f574b958a2ec84ac2f))
* **swag:** larkmox ([23d3df9](https://gitlab.com/carcheky/raspiserver/commit/23d3df95ef990a5b968c80df1ed3529cb5f2f9fb))
* **swag:** renames ([e6eb01b](https://gitlab.com/carcheky/raspiserver/commit/e6eb01b7512b5f2552e8542a75342960be8524d1))
* **swag:** udpated configs ([192fa88](https://gitlab.com/carcheky/raspiserver/commit/192fa8883cc283484dfca9789948cbfaa0700e4d))
* updated automations ([a4402d3](https://gitlab.com/carcheky/raspiserver/commit/a4402d3d313f453bc3d967bc5b72904f336f00dd))
* updated automations ([c6815a3](https://gitlab.com/carcheky/raspiserver/commit/c6815a3e5e9a9c5e56557e937e7e75b3e6212e52))

# [6.20.0](https://gitlab.com/carcheky/raspiserver/compare/v6.19.0...v6.20.0) (2024-01-07)


### Bug Fixes

* better log ([60ac1f4](https://gitlab.com/carcheky/raspiserver/commit/60ac1f483d0b9c899c20bde4877932344b64cbd7))
* better log ([e76627e](https://gitlab.com/carcheky/raspiserver/commit/e76627e26688544c47f7d37be0b52fbc98b81a6f))
* clear log on mediacheky update ([d4ba60b](https://gitlab.com/carcheky/raspiserver/commit/d4ba60bb77d926775e9baca671e7927a76989b21))
* df ([c2c8d5e](https://gitlab.com/carcheky/raspiserver/commit/c2c8d5e168d7564ee9671ea9123bb9072ddfb978))
* ignore log ([8fb0b37](https://gitlab.com/carcheky/raspiserver/commit/8fb0b37db38f3decefd136f4395e8803b5e82429))
* mediacheky update_all ([16ae757](https://gitlab.com/carcheky/raspiserver/commit/16ae7571d3fc129465319caee372214d9eb16523))
* more logs ([d81b239](https://gitlab.com/carcheky/raspiserver/commit/d81b2394a177b0178158e1c40ef51652dd8bfac3))
* mount command on update ([a34e400](https://gitlab.com/carcheky/raspiserver/commit/a34e40013b0f2a7dd1c1e70629679ca0d28eab3c))
* sudoers ([d5cdb6c](https://gitlab.com/carcheky/raspiserver/commit/d5cdb6cf5a12a4578d86bffac689d7e4abed1655))
* sudoers ([4528b16](https://gitlab.com/carcheky/raspiserver/commit/4528b163c3e7d519ca9f56ec20de5b1bd18b6286))


### Features

* intros ([ec07084](https://gitlab.com/carcheky/raspiserver/commit/ec070841d353d3dbd68538f6ed6671f799a770c0))

# [6.19.0](https://gitlab.com/carcheky/raspiserver/compare/v6.18.1...v6.19.0) (2023-12-09)


### Bug Fixes

* adguard working ([08f989c](https://gitlab.com/carcheky/raspiserver/commit/08f989c3d1194377f33af312e09df6e5d46d2ef6))
* pilhole ([b25b008](https://gitlab.com/carcheky/raspiserver/commit/b25b0083a5a61d1142698da060683ead22b36b0e))
* swag mods ([9c4c04e](https://gitlab.com/carcheky/raspiserver/commit/9c4c04ed80a943a52e9ca988257d6e7092d762df))
* **zigbee2mqtt:** first try ([7a15e6f](https://gitlab.com/carcheky/raspiserver/commit/7a15e6f86c57082e79be2ecc4601018120b622ed))


### Features

* adguad ([a930df1](https://gitlab.com/carcheky/raspiserver/commit/a930df10c792c8e4f33759590ebfe3c1a5638de0))
* adguad subdomain ([5599831](https://gitlab.com/carcheky/raspiserver/commit/5599831dde75b42e74b0743d9a2b60928c467130))

## [6.18.1](https://gitlab.com/carcheky/raspiserver/compare/v6.18.0...v6.18.1) (2023-11-27)


### Bug Fixes

* pihole nginx ([23dbf7f](https://gitlab.com/carcheky/raspiserver/commit/23dbf7f39c0238fe03c2ac049cf6465f1a71bec8))
* **pihole:** port 81 ([9091f8e](https://gitlab.com/carcheky/raspiserver/commit/9091f8eb5c74933bb46cb3baf2f2a53bf70c73cc))
* zsh configs ([d641b11](https://gitlab.com/carcheky/raspiserver/commit/d641b119adda129f495b6fe58098652130d2320d))

# [6.18.0](https://gitlab.com/carcheky/raspiserver/compare/v6.17.0...v6.18.0) (2023-11-24)


### Bug Fixes

* comitizen install ([78a5fdc](https://gitlab.com/carcheky/raspiserver/commit/78a5fdc36cd06ed27108be7ba921dd2199a4d014))
* install sudoers ([aa89566](https://gitlab.com/carcheky/raspiserver/commit/aa895663c68bade4b60b72f1e775fd40071b8c8a))
* mediacheky ([8b22930](https://gitlab.com/carcheky/raspiserver/commit/8b2293048768aa198838fa0ac64c30b288403a40))
* mediacheky ([d8ceecf](https://gitlab.com/carcheky/raspiserver/commit/d8ceecf54793de0a840210aed84bb09d254764b2))
* mediacheky ([d63e0af](https://gitlab.com/carcheky/raspiserver/commit/d63e0afafb4d494e72c3a232712f387ee80669db))
* mediacheky install ([1227d45](https://gitlab.com/carcheky/raspiserver/commit/1227d45aa4d9987efce74de23350210e058de3eb))
* mediacheky install after update ([9f879f7](https://gitlab.com/carcheky/raspiserver/commit/9f879f7b249e6eab936db3f2244442dcd0637afd))
* multiple fixes ([e8c12cc](https://gitlab.com/carcheky/raspiserver/commit/e8c12cc99e7ce41dd89d6c8959daf312fb652028))
* no dev options ([5ae40d3](https://gitlab.com/carcheky/raspiserver/commit/5ae40d30763c3d4152625906d668ca3b49e967d9))
* pihole ([52c4de7](https://gitlab.com/carcheky/raspiserver/commit/52c4de729e432bdd3035a46e7295b74fc598bcb6))
* **pihole:** fix paths ([54c48a8](https://gitlab.com/carcheky/raspiserver/commit/54c48a8ef07dfc7610fa0d8b3784bd6a6585c55f))
* reboot without password ([2c122c3](https://gitlab.com/carcheky/raspiserver/commit/2c122c3b6c9fe7d1f81032e9e1abcea79733abe4))
* remove iot ([1e5624f](https://gitlab.com/carcheky/raspiserver/commit/1e5624f65f93cdeaaa60902608c82b8e8a6504f0))
* remove orphans on update ([256d449](https://gitlab.com/carcheky/raspiserver/commit/256d4494f255e712c0a94b19c139b94358691bfa))
* sudoeres mediacheky ([3949431](https://gitlab.com/carcheky/raspiserver/commit/394943196b15d8acd225817bb77dad5f3ff10d90))
* sudoers ([c0ac48c](https://gitlab.com/carcheky/raspiserver/commit/c0ac48c3c0760e06ca8a73dbe2b6116b5d8c0686))
* sudoers ([913b936](https://gitlab.com/carcheky/raspiserver/commit/913b93674dfe1ad67ab1320dd727473c77ab99e4))
* thingsboards ([4932ecc](https://gitlab.com/carcheky/raspiserver/commit/4932eccc6829a63df9418a7458e35ada44ece8d5))
* unnatended upgrades ([123bc4f](https://gitlab.com/carcheky/raspiserver/commit/123bc4f574f548b1bbc729bdd24bfc9a4be4f2e0))
* update raspiserver on mediacheky update ([1f2f68d](https://gitlab.com/carcheky/raspiserver/commit/1f2f68d391e938d617ca8dfce7b9cd88a663dbdb))
* var in mediacheky ([d7c2784](https://gitlab.com/carcheky/raspiserver/commit/d7c27840242ecd0590a309cd167f83fc553bedde))
* **vscode:** remove extensions ([b062191](https://gitlab.com/carcheky/raspiserver/commit/b062191619a4cd2cf2c0662d6ce9e7a22149ccfc))


### Features

* added mqtt ([b48f3a2](https://gitlab.com/carcheky/raspiserver/commit/b48f3a27e228d6c9fdb91b4123c22815be5a42e3))
* new script to install zsh ([c1c6619](https://gitlab.com/carcheky/raspiserver/commit/c1c6619e30df248babfb1f591798e07b03d12980))
* pihole ([9afc03e](https://gitlab.com/carcheky/raspiserver/commit/9afc03e98b387270a6862e548a491a0b0e3c0f0e))
* thingsboard ([c0bfd9c](https://gitlab.com/carcheky/raspiserver/commit/c0bfd9ca3b0439f18e0480fc005f1b3e1f52c71a))

# [6.17.0](https://gitlab.com/carcheky/raspiserver/compare/v6.16.0...v6.17.0) (2023-11-15)


### Bug Fixes

* function ([0993278](https://gitlab.com/carcheky/raspiserver/commit/0993278f6f1f31ce2a4f31517b58e508b362c299))
* **homarr:** updated last version ([d7e70dd](https://gitlab.com/carcheky/raspiserver/commit/d7e70dd2755646e53cc62414851ce3c525aaeea5))


### Features

* **mediacheky:** mediacheky update command ([ed3a180](https://gitlab.com/carcheky/raspiserver/commit/ed3a18062fc7cbd9ba1dbb8c44c63109bf5be414))

# [6.16.0](https://gitlab.com/carcheky/raspiserver/compare/v6.15.0...v6.16.0) (2023-11-11)


### Bug Fixes

* enable backup ([42ad88c](https://gitlab.com/carcheky/raspiserver/commit/42ad88c07ca8925700fa8b220cb4bc8da121d709))
* **mediacheky:** backup ([51b2263](https://gitlab.com/carcheky/raspiserver/commit/51b22637525abe994d3e93e6aeb284d778c6c579))


### Features

* **mediacheky:** install script ([776ed6e](https://gitlab.com/carcheky/raspiserver/commit/776ed6e9f6a72b8a53d427b58d4d6d031e53cf8f))

# [6.15.0](https://gitlab.com/carcheky/raspiserver/compare/v6.14.0...v6.15.0) (2023-10-21)


### Bug Fixes

* **swag:** pihole virtual host ([df1406b](https://gitlab.com/carcheky/raspiserver/commit/df1406b6ad0218e8c9d458321ddd458e4fee5374))


### Features

* **mediacheky:** added lidarr ([4adc85c](https://gitlab.com/carcheky/raspiserver/commit/4adc85c6334c0d6bb6a5dfb33b644b43169bd22b))
* **mediacheky:** added readarr host ([63c1419](https://gitlab.com/carcheky/raspiserver/commit/63c141913689ec827935bcb5f2477e0ed9d4cb70))
* **mediacheky:** added readarr host ([e4d2337](https://gitlab.com/carcheky/raspiserver/commit/e4d2337bebf21c146e3cd041d12408fcb683b1ff))
* **mediacheky:** set backup path ([01d849a](https://gitlab.com/carcheky/raspiserver/commit/01d849ab534b274709291bf1a39b9a7a486dec7d))
* **swag:** added lidarr host ([64b6a23](https://gitlab.com/carcheky/raspiserver/commit/64b6a233f3270c296168d6fb2775e8f56e10e295))
* **swag:** added readarr host ([44bc08f](https://gitlab.com/carcheky/raspiserver/commit/44bc08f2986207ec0313b80566470a600a3e9d5c))

# [6.14.0](https://gitlab.com/carcheky/raspiserver/compare/v6.13.3...v6.14.0) (2023-10-19)


### Bug Fixes

* stable conection ([1b75e00](https://gitlab.com/carcheky/raspiserver/commit/1b75e009f91c8791a3ea22e4f6dd715b177de8fa))


### Features

* **mediacheky:** admin script ([45a2afc](https://gitlab.com/carcheky/raspiserver/commit/45a2afc3f32698e07e789d34346d370caf9d9d95))

## [6.13.3](https://gitlab.com/carcheky/raspiserver/compare/v6.13.2...v6.13.3) (2023-10-11)


### Bug Fixes

* **swag:** latest ([44ab759](https://gitlab.com/carcheky/raspiserver/commit/44ab759d2b1fb320979cc943cda7d803e09e60b8))
* **swag:** lock version to 2.6.0 ([c9b191f](https://gitlab.com/carcheky/raspiserver/commit/c9b191f1f86493f404f2644a09377e330929febf))
* **wizarr:** updated to v3 ([976515a](https://gitlab.com/carcheky/raspiserver/commit/976515af8d53d57a22a0ac964a5f7484936ec91f))

## [6.13.2](https://gitlab.com/carcheky/raspiserver/compare/v6.13.1...v6.13.2) (2023-09-27)


### Bug Fixes

* mediacheky working ([b8f58b1](https://gitlab.com/carcheky/raspiserver/commit/b8f58b1d79242ec1163d431ed4d3ce7b7d20c57c))
* point to internal server ([cf1c6f0](https://gitlab.com/carcheky/raspiserver/commit/cf1c6f0aa38a9f52238030a2746a29c5321a85a8))
* raspiserver only swag and ha ([01dc735](https://gitlab.com/carcheky/raspiserver/commit/01dc73507213ab43d6750e0a0c61e6bab111eef8))

## [6.13.1](https://gitlab.com/carcheky/raspiserver/compare/v6.13.0...v6.13.1) (2023-09-13)


### Bug Fixes

* working ([5004b2b](https://gitlab.com/carcheky/raspiserver/commit/5004b2b313be003a0a91988893520eb85232a3d3))

# [6.13.0](https://gitlab.com/carcheky/raspiserver/compare/v6.12.0...v6.13.0) (2023-09-08)


### Bug Fixes

* cron? ([491b73b](https://gitlab.com/carcheky/raspiserver/commit/491b73b958db077d3332ce5b50b6a0f4724d6f7f))
* final ([b28278a](https://gitlab.com/carcheky/raspiserver/commit/b28278aba2da49d304f3a7317ae482c1138b8d80))
* pihole ([46209ca](https://gitlab.com/carcheky/raspiserver/commit/46209cab1c55d5de7ebff4cd5d5b35ee5cfacb11))
* tz var ([17bbecc](https://gitlab.com/carcheky/raspiserver/commit/17bbecc7859a2b3d7a38fc6cf089de62def1f7a3))


### Features

* added wizarr ([3134acb](https://gitlab.com/carcheky/raspiserver/commit/3134acb03a96e0cf4e07754151ebed7d537e1a9b))

# [6.12.0](https://gitlab.com/carcheky/raspiserver/compare/v6.11.0...v6.12.0) (2023-09-04)


### Bug Fixes

* added domain for bazarr ([e7554be](https://gitlab.com/carcheky/raspiserver/commit/e7554bedc0967633e50f1a9ea5f429fa6e873496))
* cron ([8fc1900](https://gitlab.com/carcheky/raspiserver/commit/8fc1900ed8f8e0dac864fdf62945ed1823b2ff71))
* cron ([b7f2eab](https://gitlab.com/carcheky/raspiserver/commit/b7f2eab37032dbb464ae4fee3d5b45a9b40abd7c))
* cron ([c506579](https://gitlab.com/carcheky/raspiserver/commit/c506579da30618324ed4cc61f7933ccdbdd7b049))
* cron once a day ([a852cd4](https://gitlab.com/carcheky/raspiserver/commit/a852cd4dd6db89b8e34ca12339b259ed60978f23))
* date 2 times per hour ([f1d4bed](https://gitlab.com/carcheky/raspiserver/commit/f1d4bed6f449f5211b9c1a4eacc7a4c1063a5ed9))
* docker pll on boot ([4eb6f1d](https://gitlab.com/carcheky/raspiserver/commit/4eb6f1dbc4245efef0c1f4762ba3c53953eaf311))
* homarr nginx ([c282cb7](https://gitlab.com/carcheky/raspiserver/commit/c282cb7bd179d7fb2f8f64044eec119ca4c84bb1))
* open transmission port ([cc9b5a4](https://gitlab.com/carcheky/raspiserver/commit/cc9b5a4048fbf6368356385bd25bc9043732abc0))
* remove docker services as dependencies ([8c1ce6b](https://gitlab.com/carcheky/raspiserver/commit/8c1ce6b20598fed0bc8c7cbcf29109aa907bf800))


### Features

* added radarr service ([e35a62d](https://gitlab.com/carcheky/raspiserver/commit/e35a62dcfbf49c6a97c801cfba60b6e36c89911e))
* **bazaar:** added bazaar ([0691413](https://gitlab.com/carcheky/raspiserver/commit/06914131b6af77530abcd1360540e410c7020015))
* replace heimdall with homarr ([a159e66](https://gitlab.com/carcheky/raspiserver/commit/a159e66f6654cbea4399e8e3fba7969a5ef915d4))

# [6.11.0](https://gitlab.com/carcheky/raspiserver/compare/v6.10.2...v6.11.0) (2023-09-03)


### Bug Fixes

* crontab working ([abbb4bc](https://gitlab.com/carcheky/raspiserver/commit/abbb4bcfb8cbf6618b6c743e956992c8c0cc6a73))
* fix path raspiserver.log ([5926c29](https://gitlab.com/carcheky/raspiserver/commit/5926c2949757dfa4ce8bd17f6103d084c9b1abcc))
* move logs to /var/log ([ef388e4](https://gitlab.com/carcheky/raspiserver/commit/ef388e443c45a6027f37f14ba77163a7aaaa3dbd))
* removed watchtower ([5d27527](https://gitlab.com/carcheky/raspiserver/commit/5d27527ff6113979714ea4b325809231e4b10b52))


### Features

* actualizar docker images mediante cron ([a1bf987](https://gitlab.com/carcheky/raspiserver/commit/a1bf987f6f9d777df2cba0b1dde49ef62e536ca7))

## [6.10.2](https://gitlab.com/carcheky/raspiserver/compare/v6.10.1...v6.10.2) (2023-08-29)


### Bug Fixes

* source hd as var ([903ce09](https://gitlab.com/carcheky/raspiserver/commit/903ce093ec4c51b321f6c95ea6db84115da0e0dc))

## [6.10.1](https://gitlab.com/carcheky/raspiserver/compare/v6.10.0...v6.10.1) (2023-08-27)


### Bug Fixes

* only radarr ([656e4c9](https://gitlab.com/carcheky/raspiserver/commit/656e4c949ef0291206c7aacf1455ab09e72f1ad9))
* volumes for radarr ([d6e3030](https://gitlab.com/carcheky/raspiserver/commit/d6e30304864f674bf1d2afef3c463f71b5301d33))

# [6.10.0](https://gitlab.com/carcheky/raspiserver/compare/v6.9.0...v6.10.0) (2023-08-27)


### Bug Fixes

* **jellyseer:** configs ([e859dc8](https://gitlab.com/carcheky/raspiserver/commit/e859dc8b7721c2ed716f507d40e8eb736468282d))


### Features

* added heimdall ([9b15308](https://gitlab.com/carcheky/raspiserver/commit/9b153081da5f1548556cb254b651e0fba0c75ece))

# [6.9.0](https://gitlab.com/carcheky/raspiserver/compare/v6.8.2...v6.9.0) (2023-08-25)


### Bug Fixes

* enable ssl ([d4155b7](https://gitlab.com/carcheky/raspiserver/commit/d4155b7939d6012a6901abdef1c573aaa020c310))
* **prowlarr:** working ([0be088c](https://gitlab.com/carcheky/raspiserver/commit/0be088ca0f03fe69ba9ae15d20a4cc7255393612))
* restore index.htlm ([88bd3df](https://gitlab.com/carcheky/raspiserver/commit/88bd3df13116552718a2b8183fdbd044101723b5))


### Features

* **lidarr:** added lidarr ([c40c641](https://gitlab.com/carcheky/raspiserver/commit/c40c641f0384aa4844ba3696f0f2d5e0af6fcff6))
* **prowlarr:** added prowlarr ([117a7f6](https://gitlab.com/carcheky/raspiserver/commit/117a7f675ba81808467e72a2b8da3cd290998c4c))
* **radarr:** added radarr ([df0ee66](https://gitlab.com/carcheky/raspiserver/commit/df0ee66fe68677082a89ba1491cb38a790d12eac))
* **sonarr:** added sonarr ([e29c82e](https://gitlab.com/carcheky/raspiserver/commit/e29c82e09cace9dbe7a8cea3dfc56be104392fd2))
* **transmission:** added transmission ([b9078c6](https://gitlab.com/carcheky/raspiserver/commit/b9078c6bee09e63991c3df565896ac35873037ff))

## [6.8.2](https://gitlab.com/carcheky/raspiserver/compare/v6.8.1...v6.8.2) (2023-07-03)


### Bug Fixes

* config ([658d1b1](https://gitlab.com/carcheky/raspiserver/commit/658d1b1c4092194c049eebc35c796296c5017b20))

## [6.8.1](https://gitlab.com/carcheky/raspiserver/compare/v6.8.0...v6.8.1) (2023-06-27)


### Bug Fixes

* mosquitto ([3d099ea](https://gitlab.com/carcheky/raspiserver/commit/3d099ea636bd14781468add7fe30dff806da4496))
* updated config ([ec6186a](https://gitlab.com/carcheky/raspiserver/commit/ec6186ab98bcd044999c0b731903bf155c8c7896))

# [6.8.0](https://gitlab.com/carcheky/raspiserver/compare/v6.7.0...v6.8.0) (2023-04-02)


### Features

* added sensor pcck power state ([b5334a7](https://gitlab.com/carcheky/raspiserver/commit/b5334a774310c837ac9dcd0e8b66592f501c21ac))
* mosquitto server ([d8aa59f](https://gitlab.com/carcheky/raspiserver/commit/d8aa59f95a5a173b32edf7427b1652486a8bbb48))

# [6.7.0](https://gitlab.com/carcheky/raspiserver/compare/v6.6.0...v6.7.0) (2023-03-29)


### Bug Fixes

* fixed make release that not pull before merge ([e571c97](https://gitlab.com/carcheky/raspiserver/commit/e571c97a174cd78479b2ac999c908c2cfc49799c))
* make release now merge develop 2 beta before ([b9f6a20](https://gitlab.com/carcheky/raspiserver/commit/b9f6a201c5343b3507207a53f9c2cccabacd2a8a))
* some fixes in scenes ([8054bfc](https://gitlab.com/carcheky/raspiserver/commit/8054bfca784cbb866b48929bbd681b78641adcc7))


### Features

* **automation:** automation battery >20 <80 for ([00e9508](https://gitlab.com/carcheky/raspiserver/commit/00e95083fd8b9083c200b5be1de7d5e00a7b3d96))

# [6.6.0](https://gitlab.com/carcheky/raspiserver/compare/v6.5.0...v6.6.0) (2023-03-17)


### Bug Fixes

* **homeassistant:** rewrited battery control automations ([6bbb314](https://gitlab.com/carcheky/raspiserver/commit/6bbb31449f581c1a91e995b226bee5115ebeaf3e))


### Features

* **makefile:** added clean command ([6ca7bad](https://gitlab.com/carcheky/raspiserver/commit/6ca7badd1ca87eb95405f3d074cd260f743cd5af))

# [6.5.0](https://gitlab.com/carcheky/raspiserver/compare/v6.4.0...v6.5.0) (2023-03-16)


### Bug Fixes

* **changelog:** rewrited changelog.md ([cf4afc3](https://gitlab.com/carcheky/raspiserver/commit/cf4afc3c05e3fffed4a2f9d2c597871471d3a0b5))
* **makefile:** go to beta branch after publish new release to stable branch ([b564fc1](https://gitlab.com/carcheky/raspiserver/commit/b564fc16d0e163f6d2836eb1114eedff411c7eea))
* **makefile:** renamed new-release command to release ([4708777](https://gitlab.com/carcheky/raspiserver/commit/47087771733aa71d0a26dbc3fa95b8980f9471e1))


### Features

* **comitizen-install.sh:** added script for install comitizen ([f0104f7](https://gitlab.com/carcheky/raspiserver/commit/f0104f79d99900e43c912e129495dfbd6377ca71))
* **makefile:** added new command make commit ([8a4a6eb](https://gitlab.com/carcheky/raspiserver/commit/8a4a6eb4581d0e7b883a0a41a24b5a21c7f9d023))
* **makefile:** feature command ([2537b3c](https://gitlab.com/carcheky/raspiserver/commit/2537b3c45c22619e2c87a672c4880fd064c47402))

# [6.4.0](https://gitlab.com/carcheky/raspiserver/compare/v6.3.0...v6.4.0) (2023-03-16)


### Bug Fixes

* **makefile:** no edit commit message when update beta from stable ([3831173](https://gitlab.com/carcheky/raspiserver/commit/3831173ae8696575dc7ec60a07b8973b075a5e1b))
* **makefile:** renamed make command beta to beta-update ([6814ee6](https://gitlab.com/carcheky/raspiserver/commit/6814ee6a10f9886190af64c7bcf7358b54d629ca))


### Features

* **makefile:** new make command new-release ([bca0081](https://gitlab.com/carcheky/raspiserver/commit/bca0081b6032db955f29f367130bbb3dc9aa3a53))

# [6.3.0](https://gitlab.com/carcheky/raspiserver/compare/v6.2.0...v6.3.0) (2023-03-16)


### Features

* auto install script for small tower ([d6d01c5](https://gitlab.com/carcheky/raspiserver/commit/d6d01c55b5a502d8690f3fc7d3fba70540b91bba))

# [6.2.0](https://gitlab.com/carcheky/raspiserver/compare/v6.1.0...v6.2.0) (2023-01-21)


### Bug Fixes

* remove diun ([e52cd0b](https://gitlab.com/carcheky/raspiserver/commit/e52cd0ba94d595cc2aeb06979487ba867310d46a))


### Features

* working zigbee & watchtower ([456bfed](https://gitlab.com/carcheky/raspiserver/commit/456bfed568c07f9a9e5f12535b6c758d6dc76597))

# [6.1.0](https://gitlab.com/carcheky/raspiserver/compare/v6.0.0...v6.1.0) (2023-01-08)


### Features

* google assistant ([b2446d4](https://gitlab.com/carcheky/raspiserver/commit/b2446d4e5b2874d52ebcf037047be5f26b090f05))
* wake on lan ([1efd1e6](https://gitlab.com/carcheky/raspiserver/commit/1efd1e6ed7b1a571371693d6e0407f6e0e17c2f3))

# [6.0.0](https://gitlab.com/carcheky/raspiserver/compare/v5.6.0...v6.0.0) (2023-01-08)


### Bug Fixes

* .env vars ([b086516](https://gitlab.com/carcheky/raspiserver/commit/b086516ff3dd9ac7e459c7c72b28290e34025abe))
* added some vars to install script ([ed9a536](https://gitlab.com/carcheky/raspiserver/commit/ed9a53603a68aa675f5759b2d333996ced19d872))
* clone whithout sudo ([8726397](https://gitlab.com/carcheky/raspiserver/commit/8726397de137965f524bba66f596a819acf13685))
* down & stop commands ([26dacad](https://gitlab.com/carcheky/raspiserver/commit/26dacad9a417652f0a8782c8836ffb8ecbb6c985))
* export vars to .env ([6c39362](https://gitlab.com/carcheky/raspiserver/commit/6c39362e0ed283c55fcf2c95b75601b3bb5932c4))
* filetype for media hdd ([b75d4ce](https://gitlab.com/carcheky/raspiserver/commit/b75d4cebb05148b5b31a1b83c884e9d796668282))
* git clone script path ([cb2ea0f](https://gitlab.com/carcheky/raspiserver/commit/cb2ea0fb8700fd4b630f4468fbb4786b7b275b49))
* install script ([a87287f](https://gitlab.com/carcheky/raspiserver/commit/a87287f314f11c93f03ec156f14d8e907f8d798d))
* install script select beta channel ([f88ee92](https://gitlab.com/carcheky/raspiserver/commit/f88ee92de5c00acdb5784e90f49e0b575dba80bd))
* new zsh install ([23cc38d](https://gitlab.com/carcheky/raspiserver/commit/23cc38d3115a010a2ebe4e735a2934affbf4bf17))
* nextcloud database host on nextcloud-server ([417cd47](https://gitlab.com/carcheky/raspiserver/commit/417cd47471374ab61def341ee669dc792f5de277))
* no mount on kill or down ([589a083](https://gitlab.com/carcheky/raspiserver/commit/589a083f5d46c9dedf2917d8727e3b43ca2b88fd))
* only ask on clone ([b7d5080](https://gitlab.com/carcheky/raspiserver/commit/b7d5080342202e3a12d69c5f9b114243ec7f7cf7))
* renamed nextcloud containers/paths ([f077043](https://gitlab.com/carcheky/raspiserver/commit/f077043205c747a1bdbd0a3fc003bc1e42574849))
* script dirs ([ecc754b](https://gitlab.com/carcheky/raspiserver/commit/ecc754b332f451fce13961693a9d69f75e8b887e))
* script install ([3005b2b](https://gitlab.com/carcheky/raspiserver/commit/3005b2ba9d9eb7dd1604b4658f68456fb9bc1f03))
* script install ([fdd0195](https://gitlab.com/carcheky/raspiserver/commit/fdd0195fdf06b8d5963860772212f3b8ba7e3610))
* script run ([3de2a6f](https://gitlab.com/carcheky/raspiserver/commit/3de2a6f910827013559f601ba2273f3f6078b524))
* set -eux on non stable channels ([a628055](https://gitlab.com/carcheky/raspiserver/commit/a6280551197cd7cae1f7e4ebca5929a63cc3cee9))
* show channel selected ([8bcc876](https://gitlab.com/carcheky/raspiserver/commit/8bcc876ddf71d444371984df274a8f22ec63d707))
* transmission ([7566899](https://gitlab.com/carcheky/raspiserver/commit/756689932f153417fcd9b53e79f444a32938646e))
* transmission ([7c30446](https://gitlab.com/carcheky/raspiserver/commit/7c30446f617d85ece791be49f22bd95f73f44d2f))


### Features

* :fire: transmission working ([d4fbcfd](https://gitlab.com/carcheky/raspiserver/commit/d4fbcfd46d49413e0cfb61dc270e5f698f4e1dfc))
* enable nextcloud & mariadb ([c7529e5](https://gitlab.com/carcheky/raspiserver/commit/c7529e58c4d820cb16a2bc04caf7619943e8994b))
* homeassistant ([796474b](https://gitlab.com/carcheky/raspiserver/commit/796474bb621561bf4c4adf0c7b40aed56288e714))
* homeassistant working ([fbeb2fb](https://gitlab.com/carcheky/raspiserver/commit/fbeb2fb68da472a18e63c7d0834793f99df0ff5d))
* jellyfin ([742e7bb](https://gitlab.com/carcheky/raspiserver/commit/742e7bb5e15ade9c626d2219ac8c0e9be6b8883f))
* mariadb working ([a8c5871](https://gitlab.com/carcheky/raspiserver/commit/a8c5871f5073749b4f03af97fac7515ca36f5c38))
* nextcloud working ([700f661](https://gitlab.com/carcheky/raspiserver/commit/700f661a2c0f861a9b666d40b7f2ba133c61dd71))
* release new version ([852690a](https://gitlab.com/carcheky/raspiserver/commit/852690a75a75d5f072b826203ef78cabcde4f17c))
* renamed paths ([47d736b](https://gitlab.com/carcheky/raspiserver/commit/47d736bd682458d8d916901cc833b8441cd00572))
* select channel on install ([ee17899](https://gitlab.com/carcheky/raspiserver/commit/ee17899b798f987a26c3b955e355c8fb205492bc))
* set -eux on chanels beta&alpha ([650326f](https://gitlab.com/carcheky/raspiserver/commit/650326fcdfb1e4775a498f36b71b1900d532e3d9))
* transmission ([d08682a](https://gitlab.com/carcheky/raspiserver/commit/d08682a66c6ced8f692f3ae1e27fb4db3cb507ab))
* working environment ([ee08a94](https://gitlab.com/carcheky/raspiserver/commit/ee08a9443a2551bfd9cc93f261a3ac9dcec6711f))
* working nextcloud ([200363d](https://gitlab.com/carcheky/raspiserver/commit/200363d27633a8a7dd3632a1fa4a60dcce09faca))
* working nextcloud ([f0ca680](https://gitlab.com/carcheky/raspiserver/commit/f0ca6809d8cbf8959b165bdc58c148e5958139e8))
* working nextcloud ([41847e8](https://gitlab.com/carcheky/raspiserver/commit/41847e865b7ee4e980986db99bdb5dcaf450ee29))
* working! ([f60535a](https://gitlab.com/carcheky/raspiserver/commit/f60535ab73755f270bac9caa72a2dfc585de1756))


### BREAKING CHANGES

* Reworked, clean install

# [5.6.0](https://gitlab.com/carcheky/raspiserver/compare/v5.5.0...v5.6.0) (2022-12-25)


### Bug Fixes

* diun network mode host ([b241f35](https://gitlab.com/carcheky/raspiserver/commit/b241f35816925a6ee920d6712a94a3d87add77ed))


### Features

* nextcloud domain ([ee05a73](https://gitlab.com/carcheky/raspiserver/commit/ee05a73f88a06569414fa07fdde48237a7a1208a))

# [5.5.0](https://gitlab.com/carcheky/raspiserver/compare/v5.4.0...v5.5.0) (2022-12-01)


### Bug Fixes

* restart always ([a4b1129](https://gitlab.com/carcheky/raspiserver/commit/a4b1129992d1a8d1bb7b07719d8324f120b7b9db))


### Features

* network host ([6c93739](https://gitlab.com/carcheky/raspiserver/commit/6c9373920ed323befaa008047e5eb54111247a82))

# [5.4.0](https://gitlab.com/carcheky/raspiserver/compare/v5.3.0...v5.4.0) (2022-11-07)


### Bug Fixes

* remove homeassistant entrypoint ([dbd2c5f](https://gitlab.com/carcheky/raspiserver/commit/dbd2c5f0093b44fd46e0e337f8b3d0a7f6da5811))


### Features

* auto vhosts with letsencrypt ([4f6566a](https://gitlab.com/carcheky/raspiserver/commit/4f6566a5bdce6f5b71ffd538b2c85674c0e41a82))
* letsencrypt staging ([600a463](https://gitlab.com/carcheky/raspiserver/commit/600a4632b8cf52bdff148d843f7b0bbf0e95df34))
* nginx server ([d27c5f2](https://gitlab.com/carcheky/raspiserver/commit/d27c5f22c81ef8b9a0205d6ef6eb682aeb19ac78))
* working auto vhosts ([e47f727](https://gitlab.com/carcheky/raspiserver/commit/e47f72724d02c4541ead5f01cd2658d63eb13da7))

# [5.3.0](https://gitlab.com/carcheky/raspiserver/compare/v5.2.1...v5.3.0) (2022-10-29)


### Bug Fixes

* containers ([f76667a](https://gitlab.com/carcheky/raspiserver/commit/f76667a8de6fa5c7cb7a6bd730f093064b10396b))
* network mode ([aa0d319](https://gitlab.com/carcheky/raspiserver/commit/aa0d3196ae8756f5208a4f8581d333e7a3bce1ea))
* pkcs12 gen ([f882f91](https://gitlab.com/carcheky/raspiserver/commit/f882f9183a1a291ca1262e2af4c273d7424bae21))


### Features

* clean docker services ([e3dcc62](https://gitlab.com/carcheky/raspiserver/commit/e3dcc6283f0136ec2de0bfeb101dc9e69e32ffc9))
* clean docker services ([c7b6cab](https://gitlab.com/carcheky/raspiserver/commit/c7b6cab7c47f86760d19a59145e09977242b437c))
* dnsmasq ([f0e9c33](https://gitlab.com/carcheky/raspiserver/commit/f0e9c33c2b38bbfd6b966bce79fd436bd15c58d5))
* dnsmasq ([b735528](https://gitlab.com/carcheky/raspiserver/commit/b7355283ca7952ffb085d35511085c84e8c88fb4))
* dnsmasq ([dd98558](https://gitlab.com/carcheky/raspiserver/commit/dd985587a8a56335f0b0f6d4398a8b10b4b3691b))
* dnsmasq ([285af28](https://gitlab.com/carcheky/raspiserver/commit/285af2864dfa3ec35f60c8b8ec534e5ce8b53373))
* working ([3d37708](https://gitlab.com/carcheky/raspiserver/commit/3d37708d59dede9cddfd1cccada40332094f9f7d))

## [5.2.1](https://gitlab.com/carcheky/raspiserver/compare/v5.2.0...v5.2.1) (2022-10-26)


### Bug Fixes

* remove autoupdate ([108a356](https://gitlab.com/carcheky/raspiserver/commit/108a35629417cb4727f4058a298f3c835a0fc513))

# [5.2.0](https://gitlab.com/carcheky/raspiserver/compare/v5.1.1...v5.2.0) (2022-10-24)


### Bug Fixes

* docker-compose portainer ([754d8e4](https://gitlab.com/carcheky/raspiserver/commit/754d8e4f122e44e33cc951239a9eaa22ddc9a2fc))
* homeassistant cert ([9695146](https://gitlab.com/carcheky/raspiserver/commit/96951467a984096c5262b52a7040150872f777b8))
* homeassistant cert ([d605646](https://gitlab.com/carcheky/raspiserver/commit/d605646dc396e29eb9e18305c5cf1d3ba8e0918b))
* homeassistant cert ([2c65b71](https://gitlab.com/carcheky/raspiserver/commit/2c65b71bfa73ad4ce37e8fcf698b604cdd3d4f0f))
* homeassistant cert ([10426da](https://gitlab.com/carcheky/raspiserver/commit/10426dac5d06a0bec427e490b1763429fafc198d))
* homeassistant cert ([525b8db](https://gitlab.com/carcheky/raspiserver/commit/525b8dbbf42eaae95dc8ddf4b212a4dbcc251ba6))
* homeassistant cert ([69077ef](https://gitlab.com/carcheky/raspiserver/commit/69077eff2879916e0fe9d209a96c93c5fe8fa732))
* homeassistant cert ([308bcd9](https://gitlab.com/carcheky/raspiserver/commit/308bcd96e444aaccf1bf2fb32142702c6adecc93))
* homeassistant cert ([779b0f1](https://gitlab.com/carcheky/raspiserver/commit/779b0f15c6d1386a47318d95a99de848046ca70d))
* homeassistant cert ([d3722f9](https://gitlab.com/carcheky/raspiserver/commit/d3722f932a2ed1cd4400e8674ec20581451b62d3))
* homeassistant cert ([a9fb8c3](https://gitlab.com/carcheky/raspiserver/commit/a9fb8c30412d4bb5fc4ec926e5756099d5e3e244))
* homeassistant cert ([323c806](https://gitlab.com/carcheky/raspiserver/commit/323c8064d25049b081e4e4a5253fd9bd74139529))
* homeassistant cert ([6053a25](https://gitlab.com/carcheky/raspiserver/commit/6053a25979bbf9f784fb9112c558f233d8ad1837))
* homeassistant cert ([53324b3](https://gitlab.com/carcheky/raspiserver/commit/53324b3411b840d3b6a9930c7b41dc50ff0d9ed8))
* homeassistant cert ([76c32e1](https://gitlab.com/carcheky/raspiserver/commit/76c32e1a9e65307ad892dc3edea8ef481e5561cb))
* homeassistant cert ([247556b](https://gitlab.com/carcheky/raspiserver/commit/247556b3b4e3eb0bbaecf5cef7ec37cd5494d3ef))
* homeassistant cert ([8bef5a3](https://gitlab.com/carcheky/raspiserver/commit/8bef5a3f49f37964e375b07dc108d322c842ff9c))
* homeassistant cert ([345c98c](https://gitlab.com/carcheky/raspiserver/commit/345c98c0f744d00aa138066d9aa1905c00c35131))
* homeassistant cert ([e7c96d4](https://gitlab.com/carcheky/raspiserver/commit/e7c96d489a3005d6c076c74ed0b92bafa57d2997))
* jellyfin cert ([5619247](https://gitlab.com/carcheky/raspiserver/commit/5619247e29c564c97a9456aacbb0e36e78ea458c))
* jellyfin cert ([d36bf1e](https://gitlab.com/carcheky/raspiserver/commit/d36bf1e6a6052863e2af812fa4af8be9a6da0702))
* jellyfin cert ([6422024](https://gitlab.com/carcheky/raspiserver/commit/6422024ec4baf867ab3e98a194dfd0ec1c289965))
* jellyfin cert ([674227b](https://gitlab.com/carcheky/raspiserver/commit/674227b9e1fe2d687c3421dcca137ab91bfbdce7))
* jellyfin cert ([385d9ab](https://gitlab.com/carcheky/raspiserver/commit/385d9ab7864b39ffe00fdcb7d2f91941ccbd97db))
* jellyfin cert ([91f2c14](https://gitlab.com/carcheky/raspiserver/commit/91f2c14c8837c32d27eaf5d7b0f92ae938bc7495))
* jellyfin cert ([9675748](https://gitlab.com/carcheky/raspiserver/commit/96757482fadd4c88e74e66a0a5b0e597c656fba7))
* jellyfin cert ([d4f7de4](https://gitlab.com/carcheky/raspiserver/commit/d4f7de46ec35b612d9c4bab5e776c04557566696))
* jellyfin cert ([9453965](https://gitlab.com/carcheky/raspiserver/commit/945396580863f3c82abb28e0177906b0a5ba4100))
* jellyfin cert ([c4637e6](https://gitlab.com/carcheky/raspiserver/commit/c4637e6887ca3a89347f3d43217556f902102e53))
* jellyfin cert ([057cd2c](https://gitlab.com/carcheky/raspiserver/commit/057cd2cd74e631721dc29c270d6a9d08fd8c32ef))
* jellyfin cert ([0702225](https://gitlab.com/carcheky/raspiserver/commit/070222596aad4363c59a7e1d47d6c9eecc0152c9))
* jellyfin cert ([3ad5425](https://gitlab.com/carcheky/raspiserver/commit/3ad5425689ad88c8d38e0cd223c4c7b71f6baf61))
* jellyfin cert ([b5fbbd1](https://gitlab.com/carcheky/raspiserver/commit/b5fbbd1e50855487a67c0ff02e36ec79351a9eab))
* jellyfin cert ([4cb4807](https://gitlab.com/carcheky/raspiserver/commit/4cb4807dc145e7e8c2a76a9094a870a2c4d3de09))
* jellyfin cert ([1369774](https://gitlab.com/carcheky/raspiserver/commit/1369774a1230029f45b46cd134a2bd0b23ef07e4))


### Features

* added diun ([01183b0](https://gitlab.com/carcheky/raspiserver/commit/01183b0e37434059f279e7bef5f67a5100d697ed))
* added git-commit-helper.sh ([a1ce196](https://gitlab.com/carcheky/raspiserver/commit/a1ce1963b38507bf635fdf33e0688447df28ac1f))
* added git-commit-helper.sh ([e611f33](https://gitlab.com/carcheky/raspiserver/commit/e611f33f3e557619da3e5a0f5d7f7d81f19a1ade))
* added git-commit-helper.sh ([3797478](https://gitlab.com/carcheky/raspiserver/commit/3797478852549025b8d3ff8bcb7cec586431877b))
* added git-commit-helper.sh ([855814d](https://gitlab.com/carcheky/raspiserver/commit/855814d75d5508f2a5b891beea0cacf0dae2f30b))
* added git-commit-helper.sh ([fca441a](https://gitlab.com/carcheky/raspiserver/commit/fca441a9a2354c27c1869869b662b1e12549f2d2))
* added git-commit-helper.sh ([0817588](https://gitlab.com/carcheky/raspiserver/commit/08175887fb9c1773a52d246b49b0ac73ba875842))
* added git-commit-helper.sh ([ea884a1](https://gitlab.com/carcheky/raspiserver/commit/ea884a16e5a48ee612937dc8e347397639ce02da))
* added git-commit-helper.sh ([6c4432d](https://gitlab.com/carcheky/raspiserver/commit/6c4432d324fb212dffebf16d75a8c6def092be36))
* added git-commit-helper.sh ([1d6f71a](https://gitlab.com/carcheky/raspiserver/commit/1d6f71a720213efc377cd36c9fe3901685604aa0))
* diun ([135031e](https://gitlab.com/carcheky/raspiserver/commit/135031e3c274a84b3a5f582ed472b8c75bc89821))
* homeassistant to port 80 ([a6027d9](https://gitlab.com/carcheky/raspiserver/commit/a6027d908a6e950971f6cc0108489e0da667a153))
* homeassistant to port 80 ([c9fd10c](https://gitlab.com/carcheky/raspiserver/commit/c9fd10ce72e941ee147511eebbe5c15817881d83))
* homeassistant to port 80 ([69afe9e](https://gitlab.com/carcheky/raspiserver/commit/69afe9e2ed03f1b848a803b38e4b8211b2edcbc1))
* homeassistant to port 80 ([8d14b8f](https://gitlab.com/carcheky/raspiserver/commit/8d14b8fa917d91b353f8fc364dd44799e2426c92))
* homeassistant to port 80 ([4fa1835](https://gitlab.com/carcheky/raspiserver/commit/4fa1835f198f0af314f1750dfd2059a9099ab62d))
* jellyfin cert ([2a1180c](https://gitlab.com/carcheky/raspiserver/commit/2a1180c3b3e9f635ef379d89678250b577fd8b11))
* official homeassistant image ([7887719](https://gitlab.com/carcheky/raspiserver/commit/7887719cd551e4eb4a36fa23afc6a440b3098ab9))
* ssl ([33672f2](https://gitlab.com/carcheky/raspiserver/commit/33672f2c0edd7c9f328b70fce2658792333ddbeb))
* transmission ([ea76d6a](https://gitlab.com/carcheky/raspiserver/commit/ea76d6a9d460eaa9903d80d4d661ca8409958237))

## [5.1.1](https://gitlab.com/carcheky/raspiserver/compare/v5.1.0...v5.1.1) (2022-10-19)


### Bug Fixes

*  19 oct 2022, 0:01 ([f8a6656](https://gitlab.com/carcheky/raspiserver/commit/f8a665603bfe513fde49bf18ccc8b56b4431d92b))
* minimal transmission ([3baf8e5](https://gitlab.com/carcheky/raspiserver/commit/3baf8e590645110f5321323ea996c80663413980))
* network_mode host ([34579f9](https://gitlab.com/carcheky/raspiserver/commit/34579f9c4a02dd9c2c1686818abddd0c9b7152fb))
* user pass ([41ee46d](https://gitlab.com/carcheky/raspiserver/commit/41ee46d3920d56ee8bf57d02bbd5b6eab4cf025d))

# [5.1.0](https://gitlab.com/carcheky/raspiserver/compare/v5.0.23...v5.1.0) (2022-10-18)


### Bug Fixes

* docker-compose transmission config ([b75da98](https://gitlab.com/carcheky/raspiserver/commit/b75da98e88cfb035e4c6c369e72d2cffac0d05a5))
* docker-compose.yml indent ([f97c4de](https://gitlab.com/carcheky/raspiserver/commit/f97c4dee9a6eac084507256bfc54c695666701de))
* ignore files ([8ae3d47](https://gitlab.com/carcheky/raspiserver/commit/8ae3d47dd62e69257547895dc43961a27089ccb8))


### Features

* transmission ([de2ec0f](https://gitlab.com/carcheky/raspiserver/commit/de2ec0fdd87bac93c81ea6829fa218e063550552))

## [5.0.23](https://gitlab.com/carcheky/raspiserver/compare/v5.0.22...v5.0.23) (2022-10-13)


### Bug Fixes

*  12 oct 2022, 21:40 ([ca5d8f9](https://gitlab.com/carcheky/raspiserver/commit/ca5d8f92a98e32b62ad92a8e8cf1b146fe91e998))
*  12 oct 2022, 21:40 ([a9d5fc6](https://gitlab.com/carcheky/raspiserver/commit/a9d5fc690938d1cce41beceb2d32819b34335cf2))
*  12 oct 2022, 21:42 ([0411186](https://gitlab.com/carcheky/raspiserver/commit/0411186caa1cf0ba4f08528762bca7893d9bb478))
* to-stable script ([029056d](https://gitlab.com/carcheky/raspiserver/commit/029056dac89051ef90a2f3087cfa1033841afc3f))

## [5.0.22](https://gitlab.com/carcheky/raspiserver/compare/v5.0.21...v5.0.22) (2022-10-12)


### Bug Fixes

*  Oct 11, 2022, 11:52 AM ([84154e0](https://gitlab.com/carcheky/raspiserver/commit/84154e0ae2ea25bf3faecc4d2deacf58a7439094))
*  Oct 11, 2022, 11:52 AM ([215d4ce](https://gitlab.com/carcheky/raspiserver/commit/215d4ce8db10195a6627d4ac9f37264e2c1e2a91))
*  Oct 11, 2022, 11:53 AM ([dbb899b](https://gitlab.com/carcheky/raspiserver/commit/dbb899be5d4f6acd2c497d3d1c58e6d103fe1c3c))
*  Oct 11, 2022, 11:53 AM ([1005f06](https://gitlab.com/carcheky/raspiserver/commit/1005f0694195761f5e839868f453fb5540de8b93))
*  Oct 11, 2022, 11:54 AM ([ea6eea7](https://gitlab.com/carcheky/raspiserver/commit/ea6eea765225199c96b8db1b00ddba13a30bdd64))
*  Oct 11, 2022, 11:55 AM ([59d6c68](https://gitlab.com/carcheky/raspiserver/commit/59d6c688de5dfceb897dd1177dc3777fcc7ec357))
*  Oct 11, 2022, 11:56 AM ([0cc9224](https://gitlab.com/carcheky/raspiserver/commit/0cc92244c8053842c687592f14404ea00f07136f))
*  Oct 11, 2022, 11:56 AM ([fdc63c0](https://gitlab.com/carcheky/raspiserver/commit/fdc63c06bf609026fa84c32672e963aaa9f590d8))
*  Oct 11, 2022, 11:56 AM ([73bc8d9](https://gitlab.com/carcheky/raspiserver/commit/73bc8d9751b20d4964cdcca1aa0f122a8ff4af19))
*  Oct 11, 2022, 11:57 AM ([e6682bf](https://gitlab.com/carcheky/raspiserver/commit/e6682bf2eddd2029b3cd933ca55be9d7ce8c6ffc))
*  Oct 11, 2022, 11:58 AM ([fc146a2](https://gitlab.com/carcheky/raspiserver/commit/fc146a2235a41f143ee0447468ce76d6cfd2562f))
*  Oct 11, 2022, 4:19 PM ([7b1aa8b](https://gitlab.com/carcheky/raspiserver/commit/7b1aa8b2070360b08d18a4d36bd6f6287b98a310))
*  Oct 11, 2022, 4:20 PM ([8559cbf](https://gitlab.com/carcheky/raspiserver/commit/8559cbfbc7a641ebe679cf8a7b4a4212af7ed53c))
*  Oct 11, 2022, 4:20 PM ([c42ef33](https://gitlab.com/carcheky/raspiserver/commit/c42ef337aa455eeb0517babadb3c129e788bd1d5))
*  Oct 11, 2022, 4:26 PM ([1e0513c](https://gitlab.com/carcheky/raspiserver/commit/1e0513cb7f21eec1567023c2b922fad79b1cf0a6))
*  Oct 11, 2022, 4:26 PM ([2ef3d66](https://gitlab.com/carcheky/raspiserver/commit/2ef3d66795df874b9072e2288ffddd7073c8c12b))
*  Oct 11, 2022, 4:27 PM ([d94eba0](https://gitlab.com/carcheky/raspiserver/commit/d94eba0fa1005c561a3e55de27f8d1cffecac893))
*  Oct 11, 2022, 4:27 PM ([f125276](https://gitlab.com/carcheky/raspiserver/commit/f125276691606bf8fbaec0711727b9a8bb448911))
*  Oct 11, 2022, 4:28 PM ([d6d461b](https://gitlab.com/carcheky/raspiserver/commit/d6d461b757b9c5a27fe284c6e50160d467533273))
*  Oct 11, 2022, 4:28 PM ([d37d1cd](https://gitlab.com/carcheky/raspiserver/commit/d37d1cd313c8822e56d906341c54bef885330d5b))
*  Oct 11, 2022, 4:29 PM ([5bcba3f](https://gitlab.com/carcheky/raspiserver/commit/5bcba3f8897411b03ebdaa84619521afb2a33f52))
*  Oct 11, 2022, 4:29 PM ([22d5c74](https://gitlab.com/carcheky/raspiserver/commit/22d5c746ee4a00cc6ded1e6cddf1f3bcf5922aa2))
*  Oct 11, 2022, 4:29 PM ([92e32d4](https://gitlab.com/carcheky/raspiserver/commit/92e32d4d66d6255f511a416f14f0671ce0e50ed8))
*  Oct 11, 2022, 4:29 PM ([add124b](https://gitlab.com/carcheky/raspiserver/commit/add124b1e88c41cfd4854761e59abedd0700a03a))
*  Oct 11, 2022, 4:30 PM ([82b31ec](https://gitlab.com/carcheky/raspiserver/commit/82b31ec450c5bd6953bc170a05e4795b13462bd9))
*  Oct 11, 2022, 4:30 PM ([f27e75a](https://gitlab.com/carcheky/raspiserver/commit/f27e75a72a94d61a1902f42042dc5dbe0f810e1b))
*  Oct 11, 2022, 4:30 PM ([8ab83da](https://gitlab.com/carcheky/raspiserver/commit/8ab83da24f120b968195ad2b676ce77a84a8f8ea))
*  Oct 11, 2022, 4:30 PM ([9bf9b9d](https://gitlab.com/carcheky/raspiserver/commit/9bf9b9d8a2104189bc5ee8ad13b3cc7d309e6236))
*  Oct 11, 2022, 4:31 PM ([13ae344](https://gitlab.com/carcheky/raspiserver/commit/13ae34462b602ff96694fdfbc6f64cf5c64549e3))
*  Oct 11, 2022, 4:31 PM ([22c14bb](https://gitlab.com/carcheky/raspiserver/commit/22c14bb29e9e7ad4df18b72407f465652d419e62))
*  Oct 11, 2022, 4:32 PM ([652fc85](https://gitlab.com/carcheky/raspiserver/commit/652fc85050523eb2e27e708601fa122e12ad5288))
*  Oct 11, 2022, 4:32 PM ([a65a026](https://gitlab.com/carcheky/raspiserver/commit/a65a02624f91e09bf80b570e38d6ca3b547eea61))
*  Oct 11, 2022, 4:39 PM ([1eb114f](https://gitlab.com/carcheky/raspiserver/commit/1eb114fe8f63f628abb5310411a7b89ae3c3633a))
*  Oct 11, 2022, 4:39 PM ([cf59cb4](https://gitlab.com/carcheky/raspiserver/commit/cf59cb4c524b92fc54a56bf26c2a7a674b6a3ed5))
*  Oct 11, 2022, 4:43 PM ([9a8235b](https://gitlab.com/carcheky/raspiserver/commit/9a8235b7b015baac814f4e76b66887fcaa4bb7c3))
*  Oct 11, 2022, 4:46 PM ([1ac7bc2](https://gitlab.com/carcheky/raspiserver/commit/1ac7bc2e0dca4ab512a998793b5f9a0a493f7647))
*  Oct 11, 2022, 4:47 PM ([5033d21](https://gitlab.com/carcheky/raspiserver/commit/5033d21cc07906060c2545452a5fa5d4f0f2a63a))
*  Oct 11, 2022, 4:51 PM ([1dc4cf6](https://gitlab.com/carcheky/raspiserver/commit/1dc4cf665e1becf4c8c365b0fd1e406c61fac68e))
*  Oct 11, 2022, 4:52 PM ([0aa93ad](https://gitlab.com/carcheky/raspiserver/commit/0aa93ad4a3253bd53b8298640960ccafdba39b56))
*  Oct 11, 2022, 4:52 PM ([0652660](https://gitlab.com/carcheky/raspiserver/commit/065266097ff69d80244aad8383ae60e3428016b4))
*  Oct 11, 2022, 4:54 PM ([635f6ef](https://gitlab.com/carcheky/raspiserver/commit/635f6ef1e93400c998c59479430abc54c3833722))
*  Oct 11, 2022, 4:55 PM ([1f42b2d](https://gitlab.com/carcheky/raspiserver/commit/1f42b2d5c18f1806a83fef1fc4aa7275298a5ccb))
*  Oct 11, 2022, 4:55 PM ([feb9a15](https://gitlab.com/carcheky/raspiserver/commit/feb9a15fb4696b6ab3927a7e4e23d4b7427b87ad))
*  Oct 11, 2022, 4:56 PM ([2ef94a3](https://gitlab.com/carcheky/raspiserver/commit/2ef94a372190be9380749b371a094b0447a70d38))
*  Oct 11, 2022, 4:59 PM ([1809caf](https://gitlab.com/carcheky/raspiserver/commit/1809caf1c3e75e046f5708a39bb9947234c00322))
*  Oct 11, 2022, 4:59 PM ([a2eb53d](https://gitlab.com/carcheky/raspiserver/commit/a2eb53d0c8fd9f7487a39e2b8aeaebae357f60a8))
*  Oct 11, 2022, 5:11 PM ([37a4975](https://gitlab.com/carcheky/raspiserver/commit/37a4975c650b7f974ff684d3a7096591b2253a55))
*  Oct 11, 2022, 5:12 PM ([4e50f43](https://gitlab.com/carcheky/raspiserver/commit/4e50f4356f3719b78653b9766e0ba052e510b7cc))
*  Oct 11, 2022, 5:12 PM ([d7c9ce4](https://gitlab.com/carcheky/raspiserver/commit/d7c9ce4cf2a67350f8e8d40725c06df07f6ff7bc))
*  Oct 11, 2022, 5:12 PM ([9ecaf6d](https://gitlab.com/carcheky/raspiserver/commit/9ecaf6d987610b90710da1db61a03b923dc5f26f))
*  Oct 11, 2022, 5:12 PM ([705e63a](https://gitlab.com/carcheky/raspiserver/commit/705e63aa8825b9a6e232a16b2d6b6fe659da0c9c))
*  Oct 11, 2022, 5:12 PM ([6bf55b6](https://gitlab.com/carcheky/raspiserver/commit/6bf55b654ee8f841d617c38cede48ec52f6568e8))
*  Oct 11, 2022, 5:13 PM ([1904a22](https://gitlab.com/carcheky/raspiserver/commit/1904a22c1b97ea010cc268d9251f9cc1e023d6ce))
*  Oct 11, 2022, 5:13 PM ([07ca314](https://gitlab.com/carcheky/raspiserver/commit/07ca314f4dae4c555c564b5735db09d5e0a12e7d))
*  Oct 11, 2022, 5:14 PM ([a331872](https://gitlab.com/carcheky/raspiserver/commit/a33187265bcce572444b79f1c01ad257d4610c01))
*  Oct 11, 2022, 5:14 PM ([5c16f25](https://gitlab.com/carcheky/raspiserver/commit/5c16f25654973981e8cdd94356e956a60ddefa04))
*  Oct 11, 2022, 5:16 PM ([f07dec4](https://gitlab.com/carcheky/raspiserver/commit/f07dec48a52e0a59643acabbcf25093b807e4949))
*  Oct 11, 2022, 5:17 PM ([b8d9374](https://gitlab.com/carcheky/raspiserver/commit/b8d9374f6412b21fd0184e7ab5f3e9200751b560))
*  Oct 11, 2022, 5:23 PM ([84b2951](https://gitlab.com/carcheky/raspiserver/commit/84b29512aafa3757dfba2e2b5fc752fda1988524))
*  Oct 11, 2022, 5:23 PM ([5773f81](https://gitlab.com/carcheky/raspiserver/commit/5773f81994198829362d96410ea2e26d69a4e7e7))
*  Oct 11, 2022, 5:23 PM ([79acb0d](https://gitlab.com/carcheky/raspiserver/commit/79acb0db48edf1efd39629d8e07a7638248c6666))
*  Oct 11, 2022, 5:23 PM ([425b37d](https://gitlab.com/carcheky/raspiserver/commit/425b37db65feb9ea0ccd1dff8e73de445115fcf1))
*  Oct 11, 2022, 5:23 PM ([882ba8e](https://gitlab.com/carcheky/raspiserver/commit/882ba8e4247273aff9f45abb6cd459a2cc620d78))
*  Oct 11, 2022, 5:23 PM ([af1570c](https://gitlab.com/carcheky/raspiserver/commit/af1570c54e98dd96864d5268d2c3aae7d87d30e2))
*  Oct 11, 2022, 5:24 PM ([25f52ec](https://gitlab.com/carcheky/raspiserver/commit/25f52ec4f66b91ec10e26ee5aa272dcb997d9016))
*  Oct 11, 2022, 5:24 PM ([d4310e2](https://gitlab.com/carcheky/raspiserver/commit/d4310e2557178b1029e0c2dff2177ae85d3ca2dd))
*  Oct 11, 2022, 5:32 PM ([8fb7661](https://gitlab.com/carcheky/raspiserver/commit/8fb7661c066a361d770387c441451b585e0946a2))
*  Oct 11, 2022, 5:32 PM ([e181666](https://gitlab.com/carcheky/raspiserver/commit/e181666d912a99566145d61c8c316808bd197887))
*  Oct 11, 2022, 5:33 PM ([8ea6db0](https://gitlab.com/carcheky/raspiserver/commit/8ea6db01aa652c69ae26c2ea6100fa56128be0e7))
*  Oct 11, 2022, 5:33 PM ([d622a5b](https://gitlab.com/carcheky/raspiserver/commit/d622a5b19004b2f5db7f0baa399a2d6ee75018c4))
*  Oct 11, 2022, 5:34 PM ([e99d12e](https://gitlab.com/carcheky/raspiserver/commit/e99d12e3f0830e55ce25b6e37a78781337925972))
*  Oct 11, 2022, 5:34 PM ([04d032f](https://gitlab.com/carcheky/raspiserver/commit/04d032fccedd0bbbb72d3e45170e967b215f4c23))
*  Oct 11, 2022, 5:34 PM ([af92308](https://gitlab.com/carcheky/raspiserver/commit/af92308aa12bc9fea8142d63c3d755165b3fdf14))
*  Oct 11, 2022, 5:34 PM ([39ef323](https://gitlab.com/carcheky/raspiserver/commit/39ef32367d497a57fc276768ef134e3d1274fc21))
*  Oct 11, 2022, 8:53 AM ([3db50b7](https://gitlab.com/carcheky/raspiserver/commit/3db50b7aad9786e5e2232b95cbe021245ffb7c0f))
*  Oct 11, 2022, 8:54 AM ([8581082](https://gitlab.com/carcheky/raspiserver/commit/8581082c42640384c200ff595e0426fa574109b5))
*  Oct 11, 2022, 8:56 AM ([8e3b223](https://gitlab.com/carcheky/raspiserver/commit/8e3b2237ea059bcbb86edd263cb08bb24b5c08b2))
*  Oct 11, 2022, 8:57 AM ([7fb8c9e](https://gitlab.com/carcheky/raspiserver/commit/7fb8c9ecbef59ea49e2041e81171893e5fd35568))
*  Oct 11, 2022, 9:01 AM ([ed27157](https://gitlab.com/carcheky/raspiserver/commit/ed27157249f29416d6ca0338eb8b6e5a04ac2f32))
*  Oct 11, 2022, 9:01 AM ([3d038f7](https://gitlab.com/carcheky/raspiserver/commit/3d038f7123e76cdf9be06fbd7d73f2fbe280d691))
*  Oct 11, 2022, 9:02 AM ([c6d04d7](https://gitlab.com/carcheky/raspiserver/commit/c6d04d751ebeb02de8719557f855c54eed235aef))
*  Oct 11, 2022, 9:02 AM ([09d0ff7](https://gitlab.com/carcheky/raspiserver/commit/09d0ff74cc93ba6ecb299a309fa3ccbbaa456a84))
*  Oct 11, 2022, 9:03 AM ([97feac3](https://gitlab.com/carcheky/raspiserver/commit/97feac34ee599e456458cc3b3b1d98bfb0d6e03e))
*  Oct 11, 2022, 9:04 AM ([1597d42](https://gitlab.com/carcheky/raspiserver/commit/1597d42c17c957d3b5096dda639800204f84ec9f))
*  Oct 11, 2022, 9:04 AM ([506927c](https://gitlab.com/carcheky/raspiserver/commit/506927c6ae2408d08aa4ffb0c55ecf9abd58431f))
*  Oct 11, 2022, 9:04 AM ([c350f6c](https://gitlab.com/carcheky/raspiserver/commit/c350f6c5f7d4d4fe17014ecc776aab7247cedf7a))
*  Oct 11, 2022, 9:05 AM ([f019ba5](https://gitlab.com/carcheky/raspiserver/commit/f019ba5ada0726e09dc78ee40947bb01cfe7d631))
*  Oct 11, 2022, 9:10 AM ([ba4f74e](https://gitlab.com/carcheky/raspiserver/commit/ba4f74e6f8cbc1597c177b3201d0e70e99410497))
*  Oct 11, 2022, 9:11 AM ([a5c2b61](https://gitlab.com/carcheky/raspiserver/commit/a5c2b61fdc0eddd7c98e8aa83a5c115a1c74c991))
*  Oct 11, 2022, 9:12 AM ([5dbaac6](https://gitlab.com/carcheky/raspiserver/commit/5dbaac6a3d0ce1ab8c910c0a99483bda99f19428))
*  Oct 11, 2022, 9:13 AM ([f39cd8c](https://gitlab.com/carcheky/raspiserver/commit/f39cd8c2e451ea23a6148bfc07c51a1e7721a98c))
*  Oct 11, 2022, 9:14 AM ([449fdca](https://gitlab.com/carcheky/raspiserver/commit/449fdcaa2edccfb02981cec407f69c78c36f669e))
*  Oct 11, 2022, 9:14 AM ([2739d7c](https://gitlab.com/carcheky/raspiserver/commit/2739d7c0387b4f263ba439a4b246ada3423a7190))
*  Oct 11, 2022, 9:15 AM ([8200645](https://gitlab.com/carcheky/raspiserver/commit/82006453d2fed4cc10c2e7f2d6e9c0255862583f))
*  Oct 11, 2022, 9:15 AM ([7c2ec92](https://gitlab.com/carcheky/raspiserver/commit/7c2ec923fc321615a2afacc3e96a145909b17f9c))
*  Oct 11, 2022, 9:16 AM ([0f49362](https://gitlab.com/carcheky/raspiserver/commit/0f49362934ca123d66b5d2a5960b0f5cf25333fd))
*  Oct 11, 2022, 9:16 AM ([128008e](https://gitlab.com/carcheky/raspiserver/commit/128008efd965e6f766ef61adf0d2506c7b72b030))
*  Oct 11, 2022, 9:17 AM ([5b284de](https://gitlab.com/carcheky/raspiserver/commit/5b284dee60798896818d3ea95a6307bb785716d8))
*  Oct 11, 2022, 9:20 AM ([e5fb3ac](https://gitlab.com/carcheky/raspiserver/commit/e5fb3ac7927c53a5fd4eac5e5b68dde02ff6121c))
*  Oct 11, 2022, 9:24 AM ([14a4368](https://gitlab.com/carcheky/raspiserver/commit/14a43687c6e8cf73e8efaf0b1ceb1f64a38acc3e))
*  Oct 11, 2022, 9:25 AM ([a7ad78c](https://gitlab.com/carcheky/raspiserver/commit/a7ad78cffcd38dda443d521ff7f95f7079308512))
*  Oct 11, 2022, 9:25 AM ([7970048](https://gitlab.com/carcheky/raspiserver/commit/7970048754b27d0647ccfa921b20a8dd60d60a77))
*  Oct 11, 2022, 9:25 AM ([bf76d09](https://gitlab.com/carcheky/raspiserver/commit/bf76d09bbd231de7b1484a63a5c8f96ec9b123de))
*  Oct 11, 2022, 9:25 AM ([024e114](https://gitlab.com/carcheky/raspiserver/commit/024e114958c4d674185c61f24a1f4bdf37ee733f))
*  Oct 11, 2022, 9:27 AM ([bbdd1a1](https://gitlab.com/carcheky/raspiserver/commit/bbdd1a1a370175ebd90394680e691152d6d2d40c))
*  Oct 11, 2022, 9:27 AM ([6abaa91](https://gitlab.com/carcheky/raspiserver/commit/6abaa91c6a9ab49cc809182df027fee5451a8ad8))
* ci ([e650a9a](https://gitlab.com/carcheky/raspiserver/commit/e650a9af90a56d2aadf3f933e65029ecab6b7b0d))

## [5.0.22](https://gitlab.com/carcheky/raspiserver/compare/v5.0.21...v5.0.22) (2022-10-12)


### Bug Fixes

*  Oct 11, 2022, 11:52 AM ([84154e0](https://gitlab.com/carcheky/raspiserver/commit/84154e0ae2ea25bf3faecc4d2deacf58a7439094))
*  Oct 11, 2022, 11:52 AM ([215d4ce](https://gitlab.com/carcheky/raspiserver/commit/215d4ce8db10195a6627d4ac9f37264e2c1e2a91))
*  Oct 11, 2022, 11:53 AM ([dbb899b](https://gitlab.com/carcheky/raspiserver/commit/dbb899be5d4f6acd2c497d3d1c58e6d103fe1c3c))
*  Oct 11, 2022, 11:53 AM ([1005f06](https://gitlab.com/carcheky/raspiserver/commit/1005f0694195761f5e839868f453fb5540de8b93))
*  Oct 11, 2022, 11:54 AM ([ea6eea7](https://gitlab.com/carcheky/raspiserver/commit/ea6eea765225199c96b8db1b00ddba13a30bdd64))
*  Oct 11, 2022, 11:55 AM ([59d6c68](https://gitlab.com/carcheky/raspiserver/commit/59d6c688de5dfceb897dd1177dc3777fcc7ec357))
*  Oct 11, 2022, 11:56 AM ([0cc9224](https://gitlab.com/carcheky/raspiserver/commit/0cc92244c8053842c687592f14404ea00f07136f))
*  Oct 11, 2022, 11:56 AM ([fdc63c0](https://gitlab.com/carcheky/raspiserver/commit/fdc63c06bf609026fa84c32672e963aaa9f590d8))
*  Oct 11, 2022, 11:56 AM ([73bc8d9](https://gitlab.com/carcheky/raspiserver/commit/73bc8d9751b20d4964cdcca1aa0f122a8ff4af19))
*  Oct 11, 2022, 11:57 AM ([e6682bf](https://gitlab.com/carcheky/raspiserver/commit/e6682bf2eddd2029b3cd933ca55be9d7ce8c6ffc))
*  Oct 11, 2022, 11:58 AM ([fc146a2](https://gitlab.com/carcheky/raspiserver/commit/fc146a2235a41f143ee0447468ce76d6cfd2562f))
*  Oct 11, 2022, 4:19 PM ([7b1aa8b](https://gitlab.com/carcheky/raspiserver/commit/7b1aa8b2070360b08d18a4d36bd6f6287b98a310))
*  Oct 11, 2022, 4:20 PM ([8559cbf](https://gitlab.com/carcheky/raspiserver/commit/8559cbfbc7a641ebe679cf8a7b4a4212af7ed53c))
*  Oct 11, 2022, 4:20 PM ([c42ef33](https://gitlab.com/carcheky/raspiserver/commit/c42ef337aa455eeb0517babadb3c129e788bd1d5))
*  Oct 11, 2022, 4:26 PM ([1e0513c](https://gitlab.com/carcheky/raspiserver/commit/1e0513cb7f21eec1567023c2b922fad79b1cf0a6))
*  Oct 11, 2022, 4:26 PM ([2ef3d66](https://gitlab.com/carcheky/raspiserver/commit/2ef3d66795df874b9072e2288ffddd7073c8c12b))
*  Oct 11, 2022, 4:27 PM ([d94eba0](https://gitlab.com/carcheky/raspiserver/commit/d94eba0fa1005c561a3e55de27f8d1cffecac893))
*  Oct 11, 2022, 4:27 PM ([f125276](https://gitlab.com/carcheky/raspiserver/commit/f125276691606bf8fbaec0711727b9a8bb448911))
*  Oct 11, 2022, 4:28 PM ([d6d461b](https://gitlab.com/carcheky/raspiserver/commit/d6d461b757b9c5a27fe284c6e50160d467533273))
*  Oct 11, 2022, 4:28 PM ([d37d1cd](https://gitlab.com/carcheky/raspiserver/commit/d37d1cd313c8822e56d906341c54bef885330d5b))
*  Oct 11, 2022, 4:29 PM ([5bcba3f](https://gitlab.com/carcheky/raspiserver/commit/5bcba3f8897411b03ebdaa84619521afb2a33f52))
*  Oct 11, 2022, 4:29 PM ([22d5c74](https://gitlab.com/carcheky/raspiserver/commit/22d5c746ee4a00cc6ded1e6cddf1f3bcf5922aa2))
*  Oct 11, 2022, 4:29 PM ([92e32d4](https://gitlab.com/carcheky/raspiserver/commit/92e32d4d66d6255f511a416f14f0671ce0e50ed8))
*  Oct 11, 2022, 4:29 PM ([add124b](https://gitlab.com/carcheky/raspiserver/commit/add124b1e88c41cfd4854761e59abedd0700a03a))
*  Oct 11, 2022, 4:30 PM ([82b31ec](https://gitlab.com/carcheky/raspiserver/commit/82b31ec450c5bd6953bc170a05e4795b13462bd9))
*  Oct 11, 2022, 4:30 PM ([f27e75a](https://gitlab.com/carcheky/raspiserver/commit/f27e75a72a94d61a1902f42042dc5dbe0f810e1b))
*  Oct 11, 2022, 4:30 PM ([8ab83da](https://gitlab.com/carcheky/raspiserver/commit/8ab83da24f120b968195ad2b676ce77a84a8f8ea))
*  Oct 11, 2022, 4:30 PM ([9bf9b9d](https://gitlab.com/carcheky/raspiserver/commit/9bf9b9d8a2104189bc5ee8ad13b3cc7d309e6236))
*  Oct 11, 2022, 4:31 PM ([13ae344](https://gitlab.com/carcheky/raspiserver/commit/13ae34462b602ff96694fdfbc6f64cf5c64549e3))
*  Oct 11, 2022, 4:31 PM ([22c14bb](https://gitlab.com/carcheky/raspiserver/commit/22c14bb29e9e7ad4df18b72407f465652d419e62))
*  Oct 11, 2022, 4:32 PM ([652fc85](https://gitlab.com/carcheky/raspiserver/commit/652fc85050523eb2e27e708601fa122e12ad5288))
*  Oct 11, 2022, 4:32 PM ([a65a026](https://gitlab.com/carcheky/raspiserver/commit/a65a02624f91e09bf80b570e38d6ca3b547eea61))
*  Oct 11, 2022, 4:39 PM ([1eb114f](https://gitlab.com/carcheky/raspiserver/commit/1eb114fe8f63f628abb5310411a7b89ae3c3633a))
*  Oct 11, 2022, 4:39 PM ([cf59cb4](https://gitlab.com/carcheky/raspiserver/commit/cf59cb4c524b92fc54a56bf26c2a7a674b6a3ed5))
*  Oct 11, 2022, 4:43 PM ([9a8235b](https://gitlab.com/carcheky/raspiserver/commit/9a8235b7b015baac814f4e76b66887fcaa4bb7c3))
*  Oct 11, 2022, 4:46 PM ([1ac7bc2](https://gitlab.com/carcheky/raspiserver/commit/1ac7bc2e0dca4ab512a998793b5f9a0a493f7647))
*  Oct 11, 2022, 4:47 PM ([5033d21](https://gitlab.com/carcheky/raspiserver/commit/5033d21cc07906060c2545452a5fa5d4f0f2a63a))
*  Oct 11, 2022, 4:51 PM ([1dc4cf6](https://gitlab.com/carcheky/raspiserver/commit/1dc4cf665e1becf4c8c365b0fd1e406c61fac68e))
*  Oct 11, 2022, 4:52 PM ([0aa93ad](https://gitlab.com/carcheky/raspiserver/commit/0aa93ad4a3253bd53b8298640960ccafdba39b56))
*  Oct 11, 2022, 4:52 PM ([0652660](https://gitlab.com/carcheky/raspiserver/commit/065266097ff69d80244aad8383ae60e3428016b4))
*  Oct 11, 2022, 4:54 PM ([635f6ef](https://gitlab.com/carcheky/raspiserver/commit/635f6ef1e93400c998c59479430abc54c3833722))
*  Oct 11, 2022, 4:55 PM ([1f42b2d](https://gitlab.com/carcheky/raspiserver/commit/1f42b2d5c18f1806a83fef1fc4aa7275298a5ccb))
*  Oct 11, 2022, 4:55 PM ([feb9a15](https://gitlab.com/carcheky/raspiserver/commit/feb9a15fb4696b6ab3927a7e4e23d4b7427b87ad))
*  Oct 11, 2022, 4:56 PM ([2ef94a3](https://gitlab.com/carcheky/raspiserver/commit/2ef94a372190be9380749b371a094b0447a70d38))
*  Oct 11, 2022, 4:59 PM ([1809caf](https://gitlab.com/carcheky/raspiserver/commit/1809caf1c3e75e046f5708a39bb9947234c00322))
*  Oct 11, 2022, 4:59 PM ([a2eb53d](https://gitlab.com/carcheky/raspiserver/commit/a2eb53d0c8fd9f7487a39e2b8aeaebae357f60a8))
*  Oct 11, 2022, 5:11 PM ([37a4975](https://gitlab.com/carcheky/raspiserver/commit/37a4975c650b7f974ff684d3a7096591b2253a55))
*  Oct 11, 2022, 5:12 PM ([4e50f43](https://gitlab.com/carcheky/raspiserver/commit/4e50f4356f3719b78653b9766e0ba052e510b7cc))
*  Oct 11, 2022, 5:12 PM ([d7c9ce4](https://gitlab.com/carcheky/raspiserver/commit/d7c9ce4cf2a67350f8e8d40725c06df07f6ff7bc))
*  Oct 11, 2022, 5:12 PM ([9ecaf6d](https://gitlab.com/carcheky/raspiserver/commit/9ecaf6d987610b90710da1db61a03b923dc5f26f))
*  Oct 11, 2022, 5:12 PM ([705e63a](https://gitlab.com/carcheky/raspiserver/commit/705e63aa8825b9a6e232a16b2d6b6fe659da0c9c))
*  Oct 11, 2022, 5:12 PM ([6bf55b6](https://gitlab.com/carcheky/raspiserver/commit/6bf55b654ee8f841d617c38cede48ec52f6568e8))
*  Oct 11, 2022, 5:13 PM ([1904a22](https://gitlab.com/carcheky/raspiserver/commit/1904a22c1b97ea010cc268d9251f9cc1e023d6ce))
*  Oct 11, 2022, 5:13 PM ([07ca314](https://gitlab.com/carcheky/raspiserver/commit/07ca314f4dae4c555c564b5735db09d5e0a12e7d))
*  Oct 11, 2022, 5:14 PM ([a331872](https://gitlab.com/carcheky/raspiserver/commit/a33187265bcce572444b79f1c01ad257d4610c01))
*  Oct 11, 2022, 5:14 PM ([5c16f25](https://gitlab.com/carcheky/raspiserver/commit/5c16f25654973981e8cdd94356e956a60ddefa04))
*  Oct 11, 2022, 5:16 PM ([f07dec4](https://gitlab.com/carcheky/raspiserver/commit/f07dec48a52e0a59643acabbcf25093b807e4949))
*  Oct 11, 2022, 5:17 PM ([b8d9374](https://gitlab.com/carcheky/raspiserver/commit/b8d9374f6412b21fd0184e7ab5f3e9200751b560))
*  Oct 11, 2022, 8:53 AM ([3db50b7](https://gitlab.com/carcheky/raspiserver/commit/3db50b7aad9786e5e2232b95cbe021245ffb7c0f))
*  Oct 11, 2022, 8:54 AM ([8581082](https://gitlab.com/carcheky/raspiserver/commit/8581082c42640384c200ff595e0426fa574109b5))
*  Oct 11, 2022, 8:56 AM ([8e3b223](https://gitlab.com/carcheky/raspiserver/commit/8e3b2237ea059bcbb86edd263cb08bb24b5c08b2))
*  Oct 11, 2022, 8:57 AM ([7fb8c9e](https://gitlab.com/carcheky/raspiserver/commit/7fb8c9ecbef59ea49e2041e81171893e5fd35568))
*  Oct 11, 2022, 9:01 AM ([ed27157](https://gitlab.com/carcheky/raspiserver/commit/ed27157249f29416d6ca0338eb8b6e5a04ac2f32))
*  Oct 11, 2022, 9:01 AM ([3d038f7](https://gitlab.com/carcheky/raspiserver/commit/3d038f7123e76cdf9be06fbd7d73f2fbe280d691))
*  Oct 11, 2022, 9:02 AM ([c6d04d7](https://gitlab.com/carcheky/raspiserver/commit/c6d04d751ebeb02de8719557f855c54eed235aef))
*  Oct 11, 2022, 9:02 AM ([09d0ff7](https://gitlab.com/carcheky/raspiserver/commit/09d0ff74cc93ba6ecb299a309fa3ccbbaa456a84))
*  Oct 11, 2022, 9:03 AM ([97feac3](https://gitlab.com/carcheky/raspiserver/commit/97feac34ee599e456458cc3b3b1d98bfb0d6e03e))
*  Oct 11, 2022, 9:04 AM ([1597d42](https://gitlab.com/carcheky/raspiserver/commit/1597d42c17c957d3b5096dda639800204f84ec9f))
*  Oct 11, 2022, 9:04 AM ([506927c](https://gitlab.com/carcheky/raspiserver/commit/506927c6ae2408d08aa4ffb0c55ecf9abd58431f))
*  Oct 11, 2022, 9:04 AM ([c350f6c](https://gitlab.com/carcheky/raspiserver/commit/c350f6c5f7d4d4fe17014ecc776aab7247cedf7a))
*  Oct 11, 2022, 9:05 AM ([f019ba5](https://gitlab.com/carcheky/raspiserver/commit/f019ba5ada0726e09dc78ee40947bb01cfe7d631))
*  Oct 11, 2022, 9:10 AM ([ba4f74e](https://gitlab.com/carcheky/raspiserver/commit/ba4f74e6f8cbc1597c177b3201d0e70e99410497))
*  Oct 11, 2022, 9:11 AM ([a5c2b61](https://gitlab.com/carcheky/raspiserver/commit/a5c2b61fdc0eddd7c98e8aa83a5c115a1c74c991))
*  Oct 11, 2022, 9:12 AM ([5dbaac6](https://gitlab.com/carcheky/raspiserver/commit/5dbaac6a3d0ce1ab8c910c0a99483bda99f19428))
*  Oct 11, 2022, 9:13 AM ([f39cd8c](https://gitlab.com/carcheky/raspiserver/commit/f39cd8c2e451ea23a6148bfc07c51a1e7721a98c))
*  Oct 11, 2022, 9:14 AM ([449fdca](https://gitlab.com/carcheky/raspiserver/commit/449fdcaa2edccfb02981cec407f69c78c36f669e))
*  Oct 11, 2022, 9:14 AM ([2739d7c](https://gitlab.com/carcheky/raspiserver/commit/2739d7c0387b4f263ba439a4b246ada3423a7190))
*  Oct 11, 2022, 9:15 AM ([8200645](https://gitlab.com/carcheky/raspiserver/commit/82006453d2fed4cc10c2e7f2d6e9c0255862583f))
*  Oct 11, 2022, 9:15 AM ([7c2ec92](https://gitlab.com/carcheky/raspiserver/commit/7c2ec923fc321615a2afacc3e96a145909b17f9c))
*  Oct 11, 2022, 9:16 AM ([0f49362](https://gitlab.com/carcheky/raspiserver/commit/0f49362934ca123d66b5d2a5960b0f5cf25333fd))
*  Oct 11, 2022, 9:16 AM ([128008e](https://gitlab.com/carcheky/raspiserver/commit/128008efd965e6f766ef61adf0d2506c7b72b030))
*  Oct 11, 2022, 9:17 AM ([5b284de](https://gitlab.com/carcheky/raspiserver/commit/5b284dee60798896818d3ea95a6307bb785716d8))
*  Oct 11, 2022, 9:20 AM ([e5fb3ac](https://gitlab.com/carcheky/raspiserver/commit/e5fb3ac7927c53a5fd4eac5e5b68dde02ff6121c))
*  Oct 11, 2022, 9:24 AM ([14a4368](https://gitlab.com/carcheky/raspiserver/commit/14a43687c6e8cf73e8efaf0b1ceb1f64a38acc3e))
*  Oct 11, 2022, 9:25 AM ([a7ad78c](https://gitlab.com/carcheky/raspiserver/commit/a7ad78cffcd38dda443d521ff7f95f7079308512))
*  Oct 11, 2022, 9:25 AM ([7970048](https://gitlab.com/carcheky/raspiserver/commit/7970048754b27d0647ccfa921b20a8dd60d60a77))
*  Oct 11, 2022, 9:25 AM ([bf76d09](https://gitlab.com/carcheky/raspiserver/commit/bf76d09bbd231de7b1484a63a5c8f96ec9b123de))
*  Oct 11, 2022, 9:25 AM ([024e114](https://gitlab.com/carcheky/raspiserver/commit/024e114958c4d674185c61f24a1f4bdf37ee733f))
*  Oct 11, 2022, 9:27 AM ([bbdd1a1](https://gitlab.com/carcheky/raspiserver/commit/bbdd1a1a370175ebd90394680e691152d6d2d40c))
*  Oct 11, 2022, 9:27 AM ([6abaa91](https://gitlab.com/carcheky/raspiserver/commit/6abaa91c6a9ab49cc809182df027fee5451a8ad8))
* ci ([e650a9a](https://gitlab.com/carcheky/raspiserver/commit/e650a9af90a56d2aadf3f933e65029ecab6b7b0d))

## [5.0.22](https://gitlab.com/carcheky/raspiserver/compare/v5.0.21...v5.0.22) (2022-10-11)


### Bug Fixes

*  Oct 11, 2022, 11:52 AM ([84154e0](https://gitlab.com/carcheky/raspiserver/commit/84154e0ae2ea25bf3faecc4d2deacf58a7439094))
*  Oct 11, 2022, 11:52 AM ([215d4ce](https://gitlab.com/carcheky/raspiserver/commit/215d4ce8db10195a6627d4ac9f37264e2c1e2a91))
*  Oct 11, 2022, 11:53 AM ([dbb899b](https://gitlab.com/carcheky/raspiserver/commit/dbb899be5d4f6acd2c497d3d1c58e6d103fe1c3c))
*  Oct 11, 2022, 11:53 AM ([1005f06](https://gitlab.com/carcheky/raspiserver/commit/1005f0694195761f5e839868f453fb5540de8b93))
*  Oct 11, 2022, 11:54 AM ([ea6eea7](https://gitlab.com/carcheky/raspiserver/commit/ea6eea765225199c96b8db1b00ddba13a30bdd64))
*  Oct 11, 2022, 11:55 AM ([59d6c68](https://gitlab.com/carcheky/raspiserver/commit/59d6c688de5dfceb897dd1177dc3777fcc7ec357))
*  Oct 11, 2022, 11:56 AM ([0cc9224](https://gitlab.com/carcheky/raspiserver/commit/0cc92244c8053842c687592f14404ea00f07136f))
*  Oct 11, 2022, 11:56 AM ([fdc63c0](https://gitlab.com/carcheky/raspiserver/commit/fdc63c06bf609026fa84c32672e963aaa9f590d8))
*  Oct 11, 2022, 11:56 AM ([73bc8d9](https://gitlab.com/carcheky/raspiserver/commit/73bc8d9751b20d4964cdcca1aa0f122a8ff4af19))
*  Oct 11, 2022, 11:57 AM ([e6682bf](https://gitlab.com/carcheky/raspiserver/commit/e6682bf2eddd2029b3cd933ca55be9d7ce8c6ffc))
*  Oct 11, 2022, 11:58 AM ([fc146a2](https://gitlab.com/carcheky/raspiserver/commit/fc146a2235a41f143ee0447468ce76d6cfd2562f))
*  Oct 11, 2022, 4:19 PM ([7b1aa8b](https://gitlab.com/carcheky/raspiserver/commit/7b1aa8b2070360b08d18a4d36bd6f6287b98a310))
*  Oct 11, 2022, 4:20 PM ([8559cbf](https://gitlab.com/carcheky/raspiserver/commit/8559cbfbc7a641ebe679cf8a7b4a4212af7ed53c))
*  Oct 11, 2022, 4:20 PM ([c42ef33](https://gitlab.com/carcheky/raspiserver/commit/c42ef337aa455eeb0517babadb3c129e788bd1d5))
*  Oct 11, 2022, 4:26 PM ([1e0513c](https://gitlab.com/carcheky/raspiserver/commit/1e0513cb7f21eec1567023c2b922fad79b1cf0a6))
*  Oct 11, 2022, 4:26 PM ([2ef3d66](https://gitlab.com/carcheky/raspiserver/commit/2ef3d66795df874b9072e2288ffddd7073c8c12b))
*  Oct 11, 2022, 4:27 PM ([d94eba0](https://gitlab.com/carcheky/raspiserver/commit/d94eba0fa1005c561a3e55de27f8d1cffecac893))
*  Oct 11, 2022, 4:27 PM ([f125276](https://gitlab.com/carcheky/raspiserver/commit/f125276691606bf8fbaec0711727b9a8bb448911))
*  Oct 11, 2022, 4:28 PM ([d6d461b](https://gitlab.com/carcheky/raspiserver/commit/d6d461b757b9c5a27fe284c6e50160d467533273))
*  Oct 11, 2022, 4:28 PM ([d37d1cd](https://gitlab.com/carcheky/raspiserver/commit/d37d1cd313c8822e56d906341c54bef885330d5b))
*  Oct 11, 2022, 4:29 PM ([5bcba3f](https://gitlab.com/carcheky/raspiserver/commit/5bcba3f8897411b03ebdaa84619521afb2a33f52))
*  Oct 11, 2022, 4:29 PM ([22d5c74](https://gitlab.com/carcheky/raspiserver/commit/22d5c746ee4a00cc6ded1e6cddf1f3bcf5922aa2))
*  Oct 11, 2022, 4:29 PM ([92e32d4](https://gitlab.com/carcheky/raspiserver/commit/92e32d4d66d6255f511a416f14f0671ce0e50ed8))
*  Oct 11, 2022, 4:29 PM ([add124b](https://gitlab.com/carcheky/raspiserver/commit/add124b1e88c41cfd4854761e59abedd0700a03a))
*  Oct 11, 2022, 4:30 PM ([82b31ec](https://gitlab.com/carcheky/raspiserver/commit/82b31ec450c5bd6953bc170a05e4795b13462bd9))
*  Oct 11, 2022, 4:30 PM ([f27e75a](https://gitlab.com/carcheky/raspiserver/commit/f27e75a72a94d61a1902f42042dc5dbe0f810e1b))
*  Oct 11, 2022, 4:30 PM ([8ab83da](https://gitlab.com/carcheky/raspiserver/commit/8ab83da24f120b968195ad2b676ce77a84a8f8ea))
*  Oct 11, 2022, 4:30 PM ([9bf9b9d](https://gitlab.com/carcheky/raspiserver/commit/9bf9b9d8a2104189bc5ee8ad13b3cc7d309e6236))
*  Oct 11, 2022, 4:31 PM ([13ae344](https://gitlab.com/carcheky/raspiserver/commit/13ae34462b602ff96694fdfbc6f64cf5c64549e3))
*  Oct 11, 2022, 4:31 PM ([22c14bb](https://gitlab.com/carcheky/raspiserver/commit/22c14bb29e9e7ad4df18b72407f465652d419e62))
*  Oct 11, 2022, 4:32 PM ([652fc85](https://gitlab.com/carcheky/raspiserver/commit/652fc85050523eb2e27e708601fa122e12ad5288))
*  Oct 11, 2022, 4:32 PM ([a65a026](https://gitlab.com/carcheky/raspiserver/commit/a65a02624f91e09bf80b570e38d6ca3b547eea61))
*  Oct 11, 2022, 4:39 PM ([1eb114f](https://gitlab.com/carcheky/raspiserver/commit/1eb114fe8f63f628abb5310411a7b89ae3c3633a))
*  Oct 11, 2022, 4:39 PM ([cf59cb4](https://gitlab.com/carcheky/raspiserver/commit/cf59cb4c524b92fc54a56bf26c2a7a674b6a3ed5))
*  Oct 11, 2022, 4:43 PM ([9a8235b](https://gitlab.com/carcheky/raspiserver/commit/9a8235b7b015baac814f4e76b66887fcaa4bb7c3))
*  Oct 11, 2022, 4:46 PM ([1ac7bc2](https://gitlab.com/carcheky/raspiserver/commit/1ac7bc2e0dca4ab512a998793b5f9a0a493f7647))
*  Oct 11, 2022, 4:47 PM ([5033d21](https://gitlab.com/carcheky/raspiserver/commit/5033d21cc07906060c2545452a5fa5d4f0f2a63a))
*  Oct 11, 2022, 8:53 AM ([3db50b7](https://gitlab.com/carcheky/raspiserver/commit/3db50b7aad9786e5e2232b95cbe021245ffb7c0f))
*  Oct 11, 2022, 8:54 AM ([8581082](https://gitlab.com/carcheky/raspiserver/commit/8581082c42640384c200ff595e0426fa574109b5))
*  Oct 11, 2022, 8:56 AM ([8e3b223](https://gitlab.com/carcheky/raspiserver/commit/8e3b2237ea059bcbb86edd263cb08bb24b5c08b2))
*  Oct 11, 2022, 8:57 AM ([7fb8c9e](https://gitlab.com/carcheky/raspiserver/commit/7fb8c9ecbef59ea49e2041e81171893e5fd35568))
*  Oct 11, 2022, 9:01 AM ([ed27157](https://gitlab.com/carcheky/raspiserver/commit/ed27157249f29416d6ca0338eb8b6e5a04ac2f32))
*  Oct 11, 2022, 9:01 AM ([3d038f7](https://gitlab.com/carcheky/raspiserver/commit/3d038f7123e76cdf9be06fbd7d73f2fbe280d691))
*  Oct 11, 2022, 9:02 AM ([c6d04d7](https://gitlab.com/carcheky/raspiserver/commit/c6d04d751ebeb02de8719557f855c54eed235aef))
*  Oct 11, 2022, 9:02 AM ([09d0ff7](https://gitlab.com/carcheky/raspiserver/commit/09d0ff74cc93ba6ecb299a309fa3ccbbaa456a84))
*  Oct 11, 2022, 9:03 AM ([97feac3](https://gitlab.com/carcheky/raspiserver/commit/97feac34ee599e456458cc3b3b1d98bfb0d6e03e))
*  Oct 11, 2022, 9:04 AM ([1597d42](https://gitlab.com/carcheky/raspiserver/commit/1597d42c17c957d3b5096dda639800204f84ec9f))
*  Oct 11, 2022, 9:04 AM ([506927c](https://gitlab.com/carcheky/raspiserver/commit/506927c6ae2408d08aa4ffb0c55ecf9abd58431f))
*  Oct 11, 2022, 9:04 AM ([c350f6c](https://gitlab.com/carcheky/raspiserver/commit/c350f6c5f7d4d4fe17014ecc776aab7247cedf7a))
*  Oct 11, 2022, 9:05 AM ([f019ba5](https://gitlab.com/carcheky/raspiserver/commit/f019ba5ada0726e09dc78ee40947bb01cfe7d631))
*  Oct 11, 2022, 9:10 AM ([ba4f74e](https://gitlab.com/carcheky/raspiserver/commit/ba4f74e6f8cbc1597c177b3201d0e70e99410497))
*  Oct 11, 2022, 9:11 AM ([a5c2b61](https://gitlab.com/carcheky/raspiserver/commit/a5c2b61fdc0eddd7c98e8aa83a5c115a1c74c991))
*  Oct 11, 2022, 9:12 AM ([5dbaac6](https://gitlab.com/carcheky/raspiserver/commit/5dbaac6a3d0ce1ab8c910c0a99483bda99f19428))
*  Oct 11, 2022, 9:13 AM ([f39cd8c](https://gitlab.com/carcheky/raspiserver/commit/f39cd8c2e451ea23a6148bfc07c51a1e7721a98c))
*  Oct 11, 2022, 9:14 AM ([449fdca](https://gitlab.com/carcheky/raspiserver/commit/449fdcaa2edccfb02981cec407f69c78c36f669e))
*  Oct 11, 2022, 9:14 AM ([2739d7c](https://gitlab.com/carcheky/raspiserver/commit/2739d7c0387b4f263ba439a4b246ada3423a7190))
*  Oct 11, 2022, 9:15 AM ([8200645](https://gitlab.com/carcheky/raspiserver/commit/82006453d2fed4cc10c2e7f2d6e9c0255862583f))
*  Oct 11, 2022, 9:15 AM ([7c2ec92](https://gitlab.com/carcheky/raspiserver/commit/7c2ec923fc321615a2afacc3e96a145909b17f9c))
*  Oct 11, 2022, 9:16 AM ([0f49362](https://gitlab.com/carcheky/raspiserver/commit/0f49362934ca123d66b5d2a5960b0f5cf25333fd))
*  Oct 11, 2022, 9:16 AM ([128008e](https://gitlab.com/carcheky/raspiserver/commit/128008efd965e6f766ef61adf0d2506c7b72b030))
*  Oct 11, 2022, 9:17 AM ([5b284de](https://gitlab.com/carcheky/raspiserver/commit/5b284dee60798896818d3ea95a6307bb785716d8))
*  Oct 11, 2022, 9:20 AM ([e5fb3ac](https://gitlab.com/carcheky/raspiserver/commit/e5fb3ac7927c53a5fd4eac5e5b68dde02ff6121c))
*  Oct 11, 2022, 9:24 AM ([14a4368](https://gitlab.com/carcheky/raspiserver/commit/14a43687c6e8cf73e8efaf0b1ceb1f64a38acc3e))
*  Oct 11, 2022, 9:25 AM ([a7ad78c](https://gitlab.com/carcheky/raspiserver/commit/a7ad78cffcd38dda443d521ff7f95f7079308512))
*  Oct 11, 2022, 9:25 AM ([7970048](https://gitlab.com/carcheky/raspiserver/commit/7970048754b27d0647ccfa921b20a8dd60d60a77))
*  Oct 11, 2022, 9:25 AM ([bf76d09](https://gitlab.com/carcheky/raspiserver/commit/bf76d09bbd231de7b1484a63a5c8f96ec9b123de))
*  Oct 11, 2022, 9:25 AM ([024e114](https://gitlab.com/carcheky/raspiserver/commit/024e114958c4d674185c61f24a1f4bdf37ee733f))
*  Oct 11, 2022, 9:27 AM ([bbdd1a1](https://gitlab.com/carcheky/raspiserver/commit/bbdd1a1a370175ebd90394680e691152d6d2d40c))
*  Oct 11, 2022, 9:27 AM ([6abaa91](https://gitlab.com/carcheky/raspiserver/commit/6abaa91c6a9ab49cc809182df027fee5451a8ad8))
* ci ([e650a9a](https://gitlab.com/carcheky/raspiserver/commit/e650a9af90a56d2aadf3f933e65029ecab6b7b0d))

## [5.0.22](https://gitlab.com/carcheky/raspiserver/compare/v5.0.21...v5.0.22) (2022-10-11)


### Bug Fixes

*  Oct 11, 2022, 8:53 AM ([3db50b7](https://gitlab.com/carcheky/raspiserver/commit/3db50b7aad9786e5e2232b95cbe021245ffb7c0f))
*  Oct 11, 2022, 8:54 AM ([8581082](https://gitlab.com/carcheky/raspiserver/commit/8581082c42640384c200ff595e0426fa574109b5))
*  Oct 11, 2022, 8:56 AM ([8e3b223](https://gitlab.com/carcheky/raspiserver/commit/8e3b2237ea059bcbb86edd263cb08bb24b5c08b2))
*  Oct 11, 2022, 8:57 AM ([7fb8c9e](https://gitlab.com/carcheky/raspiserver/commit/7fb8c9ecbef59ea49e2041e81171893e5fd35568))
*  Oct 11, 2022, 9:01 AM ([ed27157](https://gitlab.com/carcheky/raspiserver/commit/ed27157249f29416d6ca0338eb8b6e5a04ac2f32))
*  Oct 11, 2022, 9:01 AM ([3d038f7](https://gitlab.com/carcheky/raspiserver/commit/3d038f7123e76cdf9be06fbd7d73f2fbe280d691))
*  Oct 11, 2022, 9:02 AM ([c6d04d7](https://gitlab.com/carcheky/raspiserver/commit/c6d04d751ebeb02de8719557f855c54eed235aef))
*  Oct 11, 2022, 9:02 AM ([09d0ff7](https://gitlab.com/carcheky/raspiserver/commit/09d0ff74cc93ba6ecb299a309fa3ccbbaa456a84))
*  Oct 11, 2022, 9:03 AM ([97feac3](https://gitlab.com/carcheky/raspiserver/commit/97feac34ee599e456458cc3b3b1d98bfb0d6e03e))
*  Oct 11, 2022, 9:04 AM ([1597d42](https://gitlab.com/carcheky/raspiserver/commit/1597d42c17c957d3b5096dda639800204f84ec9f))
*  Oct 11, 2022, 9:04 AM ([506927c](https://gitlab.com/carcheky/raspiserver/commit/506927c6ae2408d08aa4ffb0c55ecf9abd58431f))
*  Oct 11, 2022, 9:04 AM ([c350f6c](https://gitlab.com/carcheky/raspiserver/commit/c350f6c5f7d4d4fe17014ecc776aab7247cedf7a))
*  Oct 11, 2022, 9:05 AM ([f019ba5](https://gitlab.com/carcheky/raspiserver/commit/f019ba5ada0726e09dc78ee40947bb01cfe7d631))
*  Oct 11, 2022, 9:10 AM ([ba4f74e](https://gitlab.com/carcheky/raspiserver/commit/ba4f74e6f8cbc1597c177b3201d0e70e99410497))
*  Oct 11, 2022, 9:11 AM ([a5c2b61](https://gitlab.com/carcheky/raspiserver/commit/a5c2b61fdc0eddd7c98e8aa83a5c115a1c74c991))
*  Oct 11, 2022, 9:12 AM ([5dbaac6](https://gitlab.com/carcheky/raspiserver/commit/5dbaac6a3d0ce1ab8c910c0a99483bda99f19428))
*  Oct 11, 2022, 9:13 AM ([f39cd8c](https://gitlab.com/carcheky/raspiserver/commit/f39cd8c2e451ea23a6148bfc07c51a1e7721a98c))
*  Oct 11, 2022, 9:14 AM ([449fdca](https://gitlab.com/carcheky/raspiserver/commit/449fdcaa2edccfb02981cec407f69c78c36f669e))
*  Oct 11, 2022, 9:14 AM ([2739d7c](https://gitlab.com/carcheky/raspiserver/commit/2739d7c0387b4f263ba439a4b246ada3423a7190))
*  Oct 11, 2022, 9:15 AM ([8200645](https://gitlab.com/carcheky/raspiserver/commit/82006453d2fed4cc10c2e7f2d6e9c0255862583f))
*  Oct 11, 2022, 9:15 AM ([7c2ec92](https://gitlab.com/carcheky/raspiserver/commit/7c2ec923fc321615a2afacc3e96a145909b17f9c))
*  Oct 11, 2022, 9:16 AM ([0f49362](https://gitlab.com/carcheky/raspiserver/commit/0f49362934ca123d66b5d2a5960b0f5cf25333fd))
*  Oct 11, 2022, 9:16 AM ([128008e](https://gitlab.com/carcheky/raspiserver/commit/128008efd965e6f766ef61adf0d2506c7b72b030))
*  Oct 11, 2022, 9:17 AM ([5b284de](https://gitlab.com/carcheky/raspiserver/commit/5b284dee60798896818d3ea95a6307bb785716d8))
*  Oct 11, 2022, 9:20 AM ([e5fb3ac](https://gitlab.com/carcheky/raspiserver/commit/e5fb3ac7927c53a5fd4eac5e5b68dde02ff6121c))
*  Oct 11, 2022, 9:24 AM ([14a4368](https://gitlab.com/carcheky/raspiserver/commit/14a43687c6e8cf73e8efaf0b1ceb1f64a38acc3e))
*  Oct 11, 2022, 9:25 AM ([a7ad78c](https://gitlab.com/carcheky/raspiserver/commit/a7ad78cffcd38dda443d521ff7f95f7079308512))
*  Oct 11, 2022, 9:25 AM ([7970048](https://gitlab.com/carcheky/raspiserver/commit/7970048754b27d0647ccfa921b20a8dd60d60a77))
*  Oct 11, 2022, 9:25 AM ([bf76d09](https://gitlab.com/carcheky/raspiserver/commit/bf76d09bbd231de7b1484a63a5c8f96ec9b123de))
*  Oct 11, 2022, 9:25 AM ([024e114](https://gitlab.com/carcheky/raspiserver/commit/024e114958c4d674185c61f24a1f4bdf37ee733f))
*  Oct 11, 2022, 9:27 AM ([bbdd1a1](https://gitlab.com/carcheky/raspiserver/commit/bbdd1a1a370175ebd90394680e691152d6d2d40c))
*  Oct 11, 2022, 9:27 AM ([6abaa91](https://gitlab.com/carcheky/raspiserver/commit/6abaa91c6a9ab49cc809182df027fee5451a8ad8))
* ci ([e650a9a](https://gitlab.com/carcheky/raspiserver/commit/e650a9af90a56d2aadf3f933e65029ecab6b7b0d))

## [5.0.21](https://gitlab.com/carcheky/raspiserver/compare/v5.0.20...v5.0.21) (2022-10-11)


### Bug Fixes

*  Oct 11, 2022, 8:49 AM ([43a3315](https://gitlab.com/carcheky/raspiserver/commit/43a331533cf76f55b6615f43ca5fa659e3532cc4))

## [5.0.20](https://gitlab.com/carcheky/raspiserver/compare/v5.0.19...v5.0.20) (2022-10-11)


### Bug Fixes

*  Oct 11, 2022, 8:38 AM ([caac52c](https://gitlab.com/carcheky/raspiserver/commit/caac52c2f15a7304ff163da74cffef89561b8ba2))

## [5.0.19](https://gitlab.com/carcheky/raspiserver/compare/v5.0.18...v5.0.19) (2022-10-10)


### Bug Fixes

*  Oct 10, 2022, 10:05 PM ([a503720](https://gitlab.com/carcheky/raspiserver/commit/a50372035324d62e85ddd0aefaac6ecd15e0d102))
*  Oct 10, 2022, 10:05 PM ([af4edb9](https://gitlab.com/carcheky/raspiserver/commit/af4edb93feb97a0b4515fb63c2963dd8e8e5a443))
*  Oct 10, 2022, 10:07 PM ([5c0e96f](https://gitlab.com/carcheky/raspiserver/commit/5c0e96f873987716206e245fa48c0d635f200126))
*  Oct 10, 2022, 10:08 PM ([7c292ed](https://gitlab.com/carcheky/raspiserver/commit/7c292ed503a54c627dfca0866c2081a574611ac7))
*  Oct 10, 2022, 10:08 PM ([d625f8e](https://gitlab.com/carcheky/raspiserver/commit/d625f8e86f1a01e6e98e49b0b5ea0ea32735c63b))
*  Oct 10, 2022, 10:09 PM ([833f52e](https://gitlab.com/carcheky/raspiserver/commit/833f52e7cbb7ea80b6372c9039ebc690021a5acf))
*  Oct 10, 2022, 10:09 PM ([6d6882c](https://gitlab.com/carcheky/raspiserver/commit/6d6882c119a7d9b5f6f71bd683b690e34ac5016e))
*  Oct 10, 2022, 10:10 PM ([5eccde0](https://gitlab.com/carcheky/raspiserver/commit/5eccde019d11ccba7500d4d62c8d0d8230012e17))
*  Oct 10, 2022, 10:10 PM ([b9f5c32](https://gitlab.com/carcheky/raspiserver/commit/b9f5c32b638d782ac46e8f285106388e37198d98))
*  Oct 10, 2022, 10:11 PM ([a6c5671](https://gitlab.com/carcheky/raspiserver/commit/a6c567152a747e80fd82fdbecf2b7eb86864aaff))
*  Oct 10, 2022, 10:11 PM ([f766b0b](https://gitlab.com/carcheky/raspiserver/commit/f766b0bbe1a4f834f41788bbd75b67b0f86b5c6e))
*  Oct 10, 2022, 10:12 PM ([4630b7b](https://gitlab.com/carcheky/raspiserver/commit/4630b7b1a4e715dbbd423e3bc62020afab90cd6c))
*  Oct 10, 2022, 10:12 PM ([636e480](https://gitlab.com/carcheky/raspiserver/commit/636e480418859c90c77438614f2d909d4fb79282))
*  Oct 10, 2022, 10:13 PM ([031edf6](https://gitlab.com/carcheky/raspiserver/commit/031edf677875adb99732fc2cadf26f068b66cf0d))
*  Oct 10, 2022, 10:14 PM ([a0489f2](https://gitlab.com/carcheky/raspiserver/commit/a0489f26db12807c7e59bf7d4f60ddc3e52130f0))
*  Oct 10, 2022, 10:15 PM ([dae2375](https://gitlab.com/carcheky/raspiserver/commit/dae2375a263f18710c6b5a913bed22db3328566b))
*  Oct 10, 2022, 10:15 PM ([ef79ff5](https://gitlab.com/carcheky/raspiserver/commit/ef79ff561f01684e5d61d2ac442c0705d1e22bcb))
*  Oct 10, 2022, 10:15 PM ([0728ac7](https://gitlab.com/carcheky/raspiserver/commit/0728ac771411e224ee58c2e238c15c704c56c524))
*  Oct 10, 2022, 10:16 PM ([8c09ed8](https://gitlab.com/carcheky/raspiserver/commit/8c09ed8ca8ccbf2580473153b814cea3d6cd1066))
*  Oct 10, 2022, 10:16 PM ([f927860](https://gitlab.com/carcheky/raspiserver/commit/f9278605bd4f4bbeeacef51bf7387fdf93a7cc33))
*  Oct 10, 2022, 10:17 PM ([834d11c](https://gitlab.com/carcheky/raspiserver/commit/834d11c94ba8a4327ebd5b20c96f9a9e282507ac))
*  Oct 10, 2022, 10:22 PM ([bdc8e62](https://gitlab.com/carcheky/raspiserver/commit/bdc8e62ff523435c13f3f045e8cb4ba6c33ee52a))
*  Oct 10, 2022, 10:25 PM ([b176c53](https://gitlab.com/carcheky/raspiserver/commit/b176c530499bb9e3b0577850f8379e9998ee3bc7))
*  Oct 10, 2022, 10:25 PM ([d5aa5e9](https://gitlab.com/carcheky/raspiserver/commit/d5aa5e9a4e4f051a6e7ce46460ec4fe1ef06e963))
*  Oct 10, 2022, 10:28 PM ([0b8c7a4](https://gitlab.com/carcheky/raspiserver/commit/0b8c7a4ad68280f9e5ee143717914ef37efc7f82))
*  Oct 10, 2022, 10:31 PM ([94e6094](https://gitlab.com/carcheky/raspiserver/commit/94e6094612f2e9620cbb1d2dbaee20af51164b14))
*  Oct 10, 2022, 10:31 PM ([ac07ac4](https://gitlab.com/carcheky/raspiserver/commit/ac07ac4d84eca6ce59b899d36ccf6f2c91cb1c2d))
*  Oct 10, 2022, 10:33 PM ([c21a9a9](https://gitlab.com/carcheky/raspiserver/commit/c21a9a9edd3fe2d66b0b2b2becd63dc5d006b602))
*  Oct 10, 2022, 10:33 PM ([eabd453](https://gitlab.com/carcheky/raspiserver/commit/eabd45366514aa456ceff404f45f2c0ca082703b))
*  Oct 10, 2022, 10:36 PM ([1d57f9d](https://gitlab.com/carcheky/raspiserver/commit/1d57f9df1064bab7f9c8b23f89f601e484d8280f))
*  Oct 10, 2022, 10:36 PM ([6ffa9f1](https://gitlab.com/carcheky/raspiserver/commit/6ffa9f123d3a3855b78cf644f20b86cd55f95008))
*  Oct 10, 2022, 10:37 PM ([276b183](https://gitlab.com/carcheky/raspiserver/commit/276b1839f3e4735f1dc7b9cc631fa7087e62429c))
*  Oct 10, 2022, 10:38 PM ([e38698c](https://gitlab.com/carcheky/raspiserver/commit/e38698c92326c844c3c57644300b615ab49be1a2))
*  Oct 10, 2022, 10:41 PM ([1293099](https://gitlab.com/carcheky/raspiserver/commit/129309948b01950062cda423335adf7d118d2372))
*  Oct 10, 2022, 10:41 PM ([815bf76](https://gitlab.com/carcheky/raspiserver/commit/815bf7623afb8046ccde7a5fe91de7f83bcbb9b3))
*  Oct 10, 2022, 10:44 PM ([6392107](https://gitlab.com/carcheky/raspiserver/commit/63921071cffeb5dfea38dd2ba1e94d64703ca9f3))
*  Oct 10, 2022, 10:48 PM ([272d59b](https://gitlab.com/carcheky/raspiserver/commit/272d59b92f4cbd4cb650da439e6273471b6e14a9))
*  Oct 10, 2022, 10:48 PM ([03cad5f](https://gitlab.com/carcheky/raspiserver/commit/03cad5fe8f1b609b5264dca7a5f877e1108a4efb))
*  Oct 10, 2022, 10:48 PM ([4e9fe27](https://gitlab.com/carcheky/raspiserver/commit/4e9fe27b27f60a4fdfcfeff3bf91f52cf4ffdcaf))
*  Oct 10, 2022, 10:50 PM ([2b610e2](https://gitlab.com/carcheky/raspiserver/commit/2b610e2f5fd49045f3d74d06f957e5ecfeae9b6e))
*  Oct 10, 2022, 10:50 PM ([6e3f050](https://gitlab.com/carcheky/raspiserver/commit/6e3f05051c068e9549931ce7b7e4edd699b93974))
*  Oct 10, 2022, 10:50 PM ([d975ebe](https://gitlab.com/carcheky/raspiserver/commit/d975ebe80ebfde0d3bbf3d89d275983d90c546f6))
*  Oct 10, 2022, 10:51 PM ([8357bcf](https://gitlab.com/carcheky/raspiserver/commit/8357bcfec25ec037ede03524b8ab8a393e1d4203))
*  Oct 10, 2022, 10:51 PM ([3267fcf](https://gitlab.com/carcheky/raspiserver/commit/3267fcfb57a8518795b842f10f71c8483ea044e5))
*  Oct 10, 2022, 10:51 PM ([b362b4f](https://gitlab.com/carcheky/raspiserver/commit/b362b4f4c2ce13c5d4912b7ba60887dff3c06de3))
*  Oct 10, 2022, 10:53 PM ([d94a24e](https://gitlab.com/carcheky/raspiserver/commit/d94a24e33d92958e918f3059607eea0e292296c3))
*  Oct 10, 2022, 10:53 PM ([7421fe9](https://gitlab.com/carcheky/raspiserver/commit/7421fe9678250608355440747303b936b3139bd1))
*  Oct 10, 2022, 10:53 PM ([c745730](https://gitlab.com/carcheky/raspiserver/commit/c74573042567c3453bc0590c5ef0869f85d301a6))
*  Oct 10, 2022, 10:56 PM ([0d5bbf8](https://gitlab.com/carcheky/raspiserver/commit/0d5bbf82accad41549791e242a87e51cbc40bbfb))
*  Oct 10, 2022, 10:56 PM ([983a66d](https://gitlab.com/carcheky/raspiserver/commit/983a66dbe0eb3c7f1b71ac79c3dde4080da5a2f0))
*  Oct 10, 2022, 10:57 PM ([0540eb6](https://gitlab.com/carcheky/raspiserver/commit/0540eb67d26fd269f47c05cb1d54cb2acf1fc74b))
*  Oct 10, 2022, 10:57 PM ([51aa96d](https://gitlab.com/carcheky/raspiserver/commit/51aa96da88265624432b78e2be107f2f60e3a786))
*  Oct 10, 2022, 10:59 PM ([19c6279](https://gitlab.com/carcheky/raspiserver/commit/19c6279b7ffb223ebe707789c23a05c4170c7ef6))
*  Oct 10, 2022, 10:59 PM ([4de1870](https://gitlab.com/carcheky/raspiserver/commit/4de1870219e14e910a2e9c75f8c4ee4a0499cf55))
*  Oct 10, 2022, 11:01 PM ([fded195](https://gitlab.com/carcheky/raspiserver/commit/fded1954175f3468c6e1cf4e61e0691a89200d8a))
*  Oct 10, 2022, 11:02 PM ([cbe5686](https://gitlab.com/carcheky/raspiserver/commit/cbe568668696e9f5dc7ac2308ebb2df9feb3402e))
*  Oct 10, 2022, 11:03 PM ([9c2392c](https://gitlab.com/carcheky/raspiserver/commit/9c2392cf4df98ab6126c7095a497b702eb56077b))
*  Oct 10, 2022, 11:03 PM ([cbb1ee7](https://gitlab.com/carcheky/raspiserver/commit/cbb1ee7d9069c9d5cd3ca4df9cae53c7858d17a9))
*  Oct 10, 2022, 11:05 PM ([6d147de](https://gitlab.com/carcheky/raspiserver/commit/6d147de83c4f06857d9cc9c643e84d30a84f9707))
*  Oct 10, 2022, 11:06 PM ([2c22688](https://gitlab.com/carcheky/raspiserver/commit/2c22688e026d97801f40f8dd960a0e244e81912a))
*  Oct 10, 2022, 11:07 PM ([c5c8c07](https://gitlab.com/carcheky/raspiserver/commit/c5c8c0753f14ab53a96aaea56805b6a3867aa663))
*  Oct 10, 2022, 11:08 PM ([9822b0d](https://gitlab.com/carcheky/raspiserver/commit/9822b0db8ead92c6a514f639c055ee1dac7bbc98))
*  Oct 10, 2022, 11:10 PM ([b80cfa4](https://gitlab.com/carcheky/raspiserver/commit/b80cfa4e8d5bcb99d737bb5cb10f5beb6fb39e48))
*  Oct 10, 2022, 11:10 PM ([c65a00e](https://gitlab.com/carcheky/raspiserver/commit/c65a00eaeab1557430b7bef9eabdfaf64717a609))
*  Oct 10, 2022, 11:11 PM ([dc26260](https://gitlab.com/carcheky/raspiserver/commit/dc2626063ac09fc7155845844f32ca0019ba0f26))
*  Oct 10, 2022, 11:12 PM ([80b6fe0](https://gitlab.com/carcheky/raspiserver/commit/80b6fe0dcdc3756b605980529181363c523cc9a1))
*  Oct 10, 2022, 11:13 PM ([218b9fd](https://gitlab.com/carcheky/raspiserver/commit/218b9fd953208a9fed8b586e11e30695a6857594))
*  Oct 10, 2022, 11:14 PM ([9b6acef](https://gitlab.com/carcheky/raspiserver/commit/9b6acef25b2e695936180450263ec767f2e92343))
*  Oct 10, 2022, 11:17 PM ([efe0737](https://gitlab.com/carcheky/raspiserver/commit/efe07378233d642e9892d1e980bc009e5a4c1504))
*  Oct 10, 2022, 11:18 PM ([73e0fdf](https://gitlab.com/carcheky/raspiserver/commit/73e0fdfb7788f7836f945b770577239b00488a5e))
*  Oct 10, 2022, 11:19 PM ([649b61e](https://gitlab.com/carcheky/raspiserver/commit/649b61e2a0739cc21bc10d0b0740143ff3d754a7))
*  Oct 10, 2022, 11:19 PM ([1d3baf8](https://gitlab.com/carcheky/raspiserver/commit/1d3baf8ff19de9c2edcdc7544d1fb271cee43d17))
*  Oct 10, 2022, 11:21 PM ([7895827](https://gitlab.com/carcheky/raspiserver/commit/7895827bae0555b9e3264dd438987d6d7dc2fe8b))
*  Oct 10, 2022, 11:23 PM ([7dd9385](https://gitlab.com/carcheky/raspiserver/commit/7dd93850f92ca9c388ed8a57e63d25a470a6f646))
*  Oct 10, 2022, 11:23 PM ([b5b36d2](https://gitlab.com/carcheky/raspiserver/commit/b5b36d2529acfaa0667312e80aeac1b810d84db0))
*  Oct 10, 2022, 11:24 PM ([985b35c](https://gitlab.com/carcheky/raspiserver/commit/985b35c6dbef8a5c92b60e89276d54a1114da9bc))
*  Oct 10, 2022, 11:25 PM ([12c7705](https://gitlab.com/carcheky/raspiserver/commit/12c770581b95b391af08b49f7e2290b19d1eddad))
*  Oct 10, 2022, 11:25 PM ([f8b185c](https://gitlab.com/carcheky/raspiserver/commit/f8b185c1bf85fdfc89a8e7221a528955e49b5a69))
*  Oct 10, 2022, 11:27 PM ([51170e4](https://gitlab.com/carcheky/raspiserver/commit/51170e4ea4aa930c3f6d46ef7d6314512000ace7))
*  Oct 10, 2022, 11:29 PM ([a7ee418](https://gitlab.com/carcheky/raspiserver/commit/a7ee41884712d46044920a4cf420dd6cb428e609))
*  Oct 10, 2022, 11:29 PM ([5118127](https://gitlab.com/carcheky/raspiserver/commit/511812702c0b58930e57b388cf91dfedca9341ec))
*  Oct 10, 2022, 8:40 PM ([15c5881](https://gitlab.com/carcheky/raspiserver/commit/15c588196fa367736255c688d21d8c23286d46b2))
*  Oct 10, 2022, 8:50 PM ([9826b7f](https://gitlab.com/carcheky/raspiserver/commit/9826b7f9271ba3873b6bb1afae2e04ca923d3956))
*  Oct 10, 2022, 8:50 PM ([30cad0e](https://gitlab.com/carcheky/raspiserver/commit/30cad0eef6d2e31e9a4e20eb8a4765805e40920c))
*  Oct 10, 2022, 8:50 PM ([a286112](https://gitlab.com/carcheky/raspiserver/commit/a28611265c111c71da1c88cb34269f1354109576))
*  Oct 10, 2022, 8:51 PM ([5b03281](https://gitlab.com/carcheky/raspiserver/commit/5b032818e4f647c2287a266b42284cbb8c0df378))
*  Oct 10, 2022, 8:52 PM ([8d2f971](https://gitlab.com/carcheky/raspiserver/commit/8d2f9714631e4c3d0a4c7aeb19675a3f0813a10d))
*  Oct 10, 2022, 8:59 PM ([0d28937](https://gitlab.com/carcheky/raspiserver/commit/0d28937d16a2e9ec09bed81d5dc00a77ae0a8a25))
*  Oct 10, 2022, 9:00 PM ([06a2b0e](https://gitlab.com/carcheky/raspiserver/commit/06a2b0e16d80668ede0ff16b3a56f1c73e1b023c))
*  Oct 10, 2022, 9:01 PM ([83946a6](https://gitlab.com/carcheky/raspiserver/commit/83946a6d291eb3ec038280c4d8333449232b9dfd))
*  Oct 10, 2022, 9:14 PM ([4cfb639](https://gitlab.com/carcheky/raspiserver/commit/4cfb6396315ce4d1e518cd117871ca93860d057d))
*  Oct 10, 2022, 9:15 PM ([9d0ba29](https://gitlab.com/carcheky/raspiserver/commit/9d0ba29a631d48253eadc2e890debaa01f7e79fa))
*  Oct 10, 2022, 9:20 PM ([dd31750](https://gitlab.com/carcheky/raspiserver/commit/dd3175078fc56794eabba64cb84c5031fc355cfa))
*  Oct 10, 2022, 9:22 PM ([4fe6512](https://gitlab.com/carcheky/raspiserver/commit/4fe6512dfa8f3dbe1daa1fe087f266104a3c7cac))
*  Oct 10, 2022, 9:23 PM ([24130e3](https://gitlab.com/carcheky/raspiserver/commit/24130e390618fc1e2be01fc7d13e492932cd9ca8))
*  Oct 10, 2022, 9:23 PM ([e3909ec](https://gitlab.com/carcheky/raspiserver/commit/e3909ecd040c52aac2b114d93faf73df9aa8a49b))
*  Oct 10, 2022, 9:24 PM ([ff951fe](https://gitlab.com/carcheky/raspiserver/commit/ff951fed4cfca991418858a71206d786ad5dd5fd))
*  Oct 10, 2022, 9:32 PM ([f3a3794](https://gitlab.com/carcheky/raspiserver/commit/f3a3794e7a0ea466851ee451dd96a2046f16ce3e))
*  Oct 10, 2022, 9:37 PM ([d14457d](https://gitlab.com/carcheky/raspiserver/commit/d14457dc3b46be3b339f62efc5bfc513f2669839))
*  Oct 10, 2022, 9:38 PM ([c9854b1](https://gitlab.com/carcheky/raspiserver/commit/c9854b1de19cdaa1427ba037d8ceace05875e71a))
*  Oct 10, 2022, 9:39 PM ([7adb2fb](https://gitlab.com/carcheky/raspiserver/commit/7adb2fb35e68cbbbebc29f29a76ded2792abd60a))
*  Oct 10, 2022, 9:39 PM ([fcadbd4](https://gitlab.com/carcheky/raspiserver/commit/fcadbd42926876f8c94e537c2029986b79fafea0))
*  Oct 10, 2022, 9:40 PM ([f4a9b1d](https://gitlab.com/carcheky/raspiserver/commit/f4a9b1d5b94feedfcdca1469a326a296a55f2e28))
*  Oct 10, 2022, 9:40 PM ([d12171d](https://gitlab.com/carcheky/raspiserver/commit/d12171df73f4de66b50709a9c9c888b9499832a6))
*  Oct 10, 2022, 9:41 PM ([a6a9665](https://gitlab.com/carcheky/raspiserver/commit/a6a966514e1de8db75e09c5baaa5552c3ee068b1))
*  Oct 10, 2022, 9:41 PM ([accf9d4](https://gitlab.com/carcheky/raspiserver/commit/accf9d4f4d3f8cd22ad4bb4a03529ab6b87d4e36))
*  Oct 10, 2022, 9:42 PM ([cbd67b5](https://gitlab.com/carcheky/raspiserver/commit/cbd67b516d0db4ea4a15e396eba359a7b9370db7))
*  Oct 10, 2022, 9:42 PM ([c3f927b](https://gitlab.com/carcheky/raspiserver/commit/c3f927b3bc3c759831a9aad51d4f6bfe567c6ce6))
*  Oct 10, 2022, 9:42 PM ([efc133b](https://gitlab.com/carcheky/raspiserver/commit/efc133b542e9738b229fc7ce90cd2d391d25bc49))
*  Oct 10, 2022, 9:42 PM ([25897bb](https://gitlab.com/carcheky/raspiserver/commit/25897bbc0ec13e1c1aa4f2359f194e01f0a0ff6e))
*  Oct 10, 2022, 9:44 PM ([5945692](https://gitlab.com/carcheky/raspiserver/commit/5945692c41079f151347acaa14958d5113887573))
*  Oct 10, 2022, 9:45 PM ([c4ba2b7](https://gitlab.com/carcheky/raspiserver/commit/c4ba2b7f82cc4864a554cc8a0b902411397c1c4d))
*  Oct 10, 2022, 9:45 PM ([bb167e7](https://gitlab.com/carcheky/raspiserver/commit/bb167e7ccaf72cb70c49166a95d4b3510fd47bea))
*  Oct 10, 2022, 9:46 PM ([9c09148](https://gitlab.com/carcheky/raspiserver/commit/9c09148fdd330aeb8dd21a590b65565a9dd94cab))
*  Oct 10, 2022, 9:49 PM ([3d790ae](https://gitlab.com/carcheky/raspiserver/commit/3d790ae3afd31020ce3b87dbacb0b397aa1fe7cf))

## [5.0.18](https://gitlab.com/carcheky/raspiserver/compare/v5.0.17...v5.0.18) (2022-10-10)


### Bug Fixes

*  Oct 10, 2022, 6:26 PM ([33a8ffe](https://gitlab.com/carcheky/raspiserver/commit/33a8ffeb51d390e038c9bdba7a92e924e1f377d2))
*  Oct 10, 2022, 6:26 PM ([bbb43f1](https://gitlab.com/carcheky/raspiserver/commit/bbb43f18710278833bd77224ac585a33cdd21d49))
*  Oct 10, 2022, 6:26 PM ([d8d9e27](https://gitlab.com/carcheky/raspiserver/commit/d8d9e2786b6e86cd0fcde4a388721ae7558e1877))
*  Oct 10, 2022, 6:30 PM ([c89987e](https://gitlab.com/carcheky/raspiserver/commit/c89987e9336810cbc54f77f2acd9f1aa26d847ba))
*  Oct 10, 2022, 6:32 PM ([b6a9c78](https://gitlab.com/carcheky/raspiserver/commit/b6a9c78e9861271bd60c7f6aa702ae939cd4b870))
*  Oct 10, 2022, 6:36 PM ([f48ccfb](https://gitlab.com/carcheky/raspiserver/commit/f48ccfbd68b9fd44099c8cbae4dfa2f149ee4c3b))
*  Oct 10, 2022, 6:37 PM ([4bb22d1](https://gitlab.com/carcheky/raspiserver/commit/4bb22d1456994b35c1a959144adf787c8a68cf50))
*  Oct 10, 2022, 6:37 PM ([cf67aeb](https://gitlab.com/carcheky/raspiserver/commit/cf67aeb60d5796d82d84ad10d95f524a060d2517))
*  Oct 10, 2022, 6:40 PM ([2e01c8c](https://gitlab.com/carcheky/raspiserver/commit/2e01c8c8c3566c1c061aba7a0304fe9bfb46845c))
*  Oct 10, 2022, 6:41 PM ([0ee94dc](https://gitlab.com/carcheky/raspiserver/commit/0ee94dc4b045c60db967435c0677f7ee2cef9b04))
*  Oct 10, 2022, 6:42 PM ([9b3b61b](https://gitlab.com/carcheky/raspiserver/commit/9b3b61b2a62a52545955109c005e539ea4961a25))
*  Oct 10, 2022, 6:42 PM ([432f94c](https://gitlab.com/carcheky/raspiserver/commit/432f94ce9183a927871494448a273eb366a61918))
*  Oct 10, 2022, 6:43 PM ([1edeea3](https://gitlab.com/carcheky/raspiserver/commit/1edeea3bf8fff0817cc0e3431773886fcf556160))
*  Oct 10, 2022, 6:45 PM ([ffb07d2](https://gitlab.com/carcheky/raspiserver/commit/ffb07d2ce468ef8b84df9ac4a51712058939ad09))
*  Oct 10, 2022, 6:45 PM ([d5b8c21](https://gitlab.com/carcheky/raspiserver/commit/d5b8c21b944effbecbec1068d5f71bae947e087d))
*  Oct 10, 2022, 6:46 PM ([b0e1252](https://gitlab.com/carcheky/raspiserver/commit/b0e12529819f84e3426be043b92aedc86b4d1e1c))
*  Oct 10, 2022, 6:48 PM ([394eac2](https://gitlab.com/carcheky/raspiserver/commit/394eac2d3908af5a963518a8d787db0c62c6e9ec))
*  Oct 10, 2022, 6:49 PM ([ef35a84](https://gitlab.com/carcheky/raspiserver/commit/ef35a8492a16f19832ee6a4a85bcc1d54abf6e32))
*  Oct 10, 2022, 6:52 PM ([31884a9](https://gitlab.com/carcheky/raspiserver/commit/31884a9f86bb0dbe7aa73b30a4ee299801a2fa7f))
*  Oct 10, 2022, 6:52 PM ([843c659](https://gitlab.com/carcheky/raspiserver/commit/843c659fe30e0366c65cf9af9323019e8016c504))
*  Oct 10, 2022, 6:53 PM ([2147075](https://gitlab.com/carcheky/raspiserver/commit/2147075e7eb407238bd5ed54af121a576c2f2ee5))
*  Oct 10, 2022, 6:54 PM ([19fd1c5](https://gitlab.com/carcheky/raspiserver/commit/19fd1c59f15fe59b93af1c3d3b005632cc24f9bf))
*  Oct 10, 2022, 6:55 PM ([0e9e628](https://gitlab.com/carcheky/raspiserver/commit/0e9e62821cb41acb04a5de36a0fa9b09d8eca000))
*  Oct 10, 2022, 6:55 PM ([eca0f7b](https://gitlab.com/carcheky/raspiserver/commit/eca0f7bfbc96af1469433f801125acbc010f788c))
*  Oct 10, 2022, 6:55 PM ([ab6d62a](https://gitlab.com/carcheky/raspiserver/commit/ab6d62a1ddadb46bdfadaf5f3413debcf0852184))
*  Oct 10, 2022, 6:57 PM ([638f62c](https://gitlab.com/carcheky/raspiserver/commit/638f62c6b18294efe38d1e29a9b478f19d960b7f))
*  Oct 10, 2022, 6:57 PM ([756e606](https://gitlab.com/carcheky/raspiserver/commit/756e6062e994fb1ee20541970c95d146e2c62691))
*  Oct 10, 2022, 6:57 PM ([e719b84](https://gitlab.com/carcheky/raspiserver/commit/e719b846f14e4e8c6b1d1cacdd5ec4ed140f0f69))
*  Oct 10, 2022, 6:57 PM ([f4c610a](https://gitlab.com/carcheky/raspiserver/commit/f4c610a09c69b3eb1fa53ec4a0d8265452a22e77))
*  Oct 10, 2022, 6:58 PM ([f054b65](https://gitlab.com/carcheky/raspiserver/commit/f054b6534f36c3ddd864801b7339e9f8816deb90))
*  Oct 10, 2022, 6:58 PM ([3193efa](https://gitlab.com/carcheky/raspiserver/commit/3193efa6f1e9a0280c3d1d4f9a7bf3c2a8656d4c))
*  Oct 10, 2022, 6:59 PM ([452f8c4](https://gitlab.com/carcheky/raspiserver/commit/452f8c4221353ba7783e21ccc129deaa6a385c92))
*  Oct 10, 2022, 6:59 PM ([8253eda](https://gitlab.com/carcheky/raspiserver/commit/8253edaf1aae0c477374bf7fc9b991259bfa9988))
*  Oct 10, 2022, 6:59 PM ([b13f059](https://gitlab.com/carcheky/raspiserver/commit/b13f059913666a54e86c3027d97c4124c3739ff3))
*  Oct 10, 2022, 6:59 PM ([d850142](https://gitlab.com/carcheky/raspiserver/commit/d8501423d0797bb1c2fc84010e78a8ac0830bf99))
*  Oct 10, 2022, 6:59 PM ([64a79a8](https://gitlab.com/carcheky/raspiserver/commit/64a79a8c9eea47913db906d04200bca943542541))
*  Oct 10, 2022, 6:59 PM ([f32f659](https://gitlab.com/carcheky/raspiserver/commit/f32f65984f632843fd6ca542935902a1ec3ad323))
*  Oct 10, 2022, 7:02 PM ([5563b78](https://gitlab.com/carcheky/raspiserver/commit/5563b78c44a265df5db24af52dce0b7935bae047))
*  Oct 10, 2022, 7:03 PM ([d876abb](https://gitlab.com/carcheky/raspiserver/commit/d876abb621c4b5145edbe8e70b40637270b22753))
*  Oct 10, 2022, 7:04 PM ([2445076](https://gitlab.com/carcheky/raspiserver/commit/24450769138cf237bceab832ecf74dd3ffa55c81))
*  Oct 10, 2022, 7:07 PM ([baf85fc](https://gitlab.com/carcheky/raspiserver/commit/baf85fc792b89f5481bb54ccfe5b0471a858b6fe))
*  Oct 10, 2022, 7:07 PM ([42929b8](https://gitlab.com/carcheky/raspiserver/commit/42929b85a645a99018c126f66cb67e43392478d5))
*  Oct 10, 2022, 7:11 PM ([0f81a85](https://gitlab.com/carcheky/raspiserver/commit/0f81a85807d559c23ace9655ae9f2ffefbe55f66))
*  Oct 10, 2022, 7:12 PM ([b3c199d](https://gitlab.com/carcheky/raspiserver/commit/b3c199dccc533e28060589c7c3337c6921296103))
*  Oct 10, 2022, 7:13 PM ([710509c](https://gitlab.com/carcheky/raspiserver/commit/710509c4bffc5f43f78ceb3a2a3a8268b6e4bb18))
*  Oct 10, 2022, 7:16 PM ([0ba6c63](https://gitlab.com/carcheky/raspiserver/commit/0ba6c63a155c89b2369039d6f236f826cbc36d71))
*  Oct 10, 2022, 7:17 PM ([ad6ebe6](https://gitlab.com/carcheky/raspiserver/commit/ad6ebe62af68722817196cf8d583d87e66867915))
*  Oct 10, 2022, 7:29 PM ([d3bdcd7](https://gitlab.com/carcheky/raspiserver/commit/d3bdcd77fb2095fbb349611f45cf1323e0eac5e3))
*  Oct 10, 2022, 7:29 PM ([e7034d2](https://gitlab.com/carcheky/raspiserver/commit/e7034d2e746aa5a44b9683ee7196c05eed74c3e6))
*  Oct 10, 2022, 7:30 PM ([4265be2](https://gitlab.com/carcheky/raspiserver/commit/4265be2a4efc1fe9cc3335fddfdfe7461e6d2565))
*  Oct 10, 2022, 7:31 PM ([f81f1b5](https://gitlab.com/carcheky/raspiserver/commit/f81f1b50da28d36e27187cfcf3a72b2490c9e2e8))
*  Oct 10, 2022, 7:32 PM ([06a1c01](https://gitlab.com/carcheky/raspiserver/commit/06a1c015553cae0b40736f6481a3dd4f9fdef663))
*  Oct 10, 2022, 7:35 PM ([41d4e8d](https://gitlab.com/carcheky/raspiserver/commit/41d4e8da72f43dd8d1a8d2ce1b9cfcd6a2891661))
*  Oct 10, 2022, 7:36 PM ([a262fc8](https://gitlab.com/carcheky/raspiserver/commit/a262fc839fe4237a65cfec9531090d56abc8947a))
*  Oct 10, 2022, 7:36 PM ([f99f04d](https://gitlab.com/carcheky/raspiserver/commit/f99f04d74cb2587b84753328034d40274be183ff))
*  Oct 10, 2022, 7:37 PM ([c33130a](https://gitlab.com/carcheky/raspiserver/commit/c33130a88f0da9ec1420a4dde7e91d6d04da0abb))
*  Oct 10, 2022, 7:37 PM ([d904102](https://gitlab.com/carcheky/raspiserver/commit/d90410262e12ff1d9319a897b3a51184e87b124e))
*  Oct 10, 2022, 7:37 PM ([10c5b08](https://gitlab.com/carcheky/raspiserver/commit/10c5b08e574994689e07894114e924fad9c472ca))
*  Oct 10, 2022, 7:39 PM ([8175680](https://gitlab.com/carcheky/raspiserver/commit/817568074e055ad24c84c81d31b237e8a287546a))
*  Oct 10, 2022, 7:41 PM ([aad7608](https://gitlab.com/carcheky/raspiserver/commit/aad760899a7d6838f254c8222b37708e1d985a4c))
*  Oct 10, 2022, 7:44 PM ([5a7c5c2](https://gitlab.com/carcheky/raspiserver/commit/5a7c5c21ff00a2d777a68010dce1173efa3c67e0))
*  Oct 10, 2022, 7:44 PM ([1cfc377](https://gitlab.com/carcheky/raspiserver/commit/1cfc37761ff13a74db8ad300ad5162d9abce3936))
*  Oct 10, 2022, 7:45 PM ([ddea0d9](https://gitlab.com/carcheky/raspiserver/commit/ddea0d9f871e69f62e61292242c79f46fa5a21d4))
*  Oct 10, 2022, 7:47 PM ([f2d3945](https://gitlab.com/carcheky/raspiserver/commit/f2d39452ed99d63a7c3cc6b8fd0d03bbab5fe263))
*  Oct 10, 2022, 7:47 PM ([28ab93d](https://gitlab.com/carcheky/raspiserver/commit/28ab93d8c3fe1a4da737f92f09c875ba7ab34464))
*  Oct 10, 2022, 7:49 PM ([b60f443](https://gitlab.com/carcheky/raspiserver/commit/b60f44333f17b5eb9eb1d9505bba7a6d6c8480df))
*  Oct 10, 2022, 7:51 PM ([4aa6b66](https://gitlab.com/carcheky/raspiserver/commit/4aa6b66b4b1854d14b09a75ad621a54e87dd3936))
*  Oct 10, 2022, 7:52 PM ([08ee573](https://gitlab.com/carcheky/raspiserver/commit/08ee5731f066b4fe59a6af384004bd7b2054a680))
*  Oct 10, 2022, 7:57 PM ([2af0877](https://gitlab.com/carcheky/raspiserver/commit/2af0877c3b67f424f76af549be828e489dca4917))
*  Oct 10, 2022, 7:59 PM ([6aadd48](https://gitlab.com/carcheky/raspiserver/commit/6aadd48df2ac6ab10f2a204868a5a02f59fb5514))
*  Oct 10, 2022, 7:59 PM ([bb9dd6b](https://gitlab.com/carcheky/raspiserver/commit/bb9dd6b2304a49d7ede24f67dc0ceae371be4fc2))
*  Oct 10, 2022, 8:06 PM ([9620e83](https://gitlab.com/carcheky/raspiserver/commit/9620e83a23d69344060740239f5dda2a51aeaf56))
*  Oct 10, 2022, 8:06 PM ([1832602](https://gitlab.com/carcheky/raspiserver/commit/1832602a32ad91e8fe6fe38ddc887b222d5ff9a8))

## [5.0.17](https://gitlab.com/carcheky/raspiserver/compare/v5.0.16...v5.0.17) (2022-10-10)


### Bug Fixes

*  Oct 10, 2022, 5:39 PM ([801a64b](https://gitlab.com/carcheky/raspiserver/commit/801a64bc678932c2dd1c6233a0e076317108c08a))
*  Oct 10, 2022, 5:39 PM ([c2884dc](https://gitlab.com/carcheky/raspiserver/commit/c2884dc3898a4a05427e47d58858a5dd943b0e94))
*  Oct 10, 2022, 5:41 PM ([9ed6ca1](https://gitlab.com/carcheky/raspiserver/commit/9ed6ca17be68dd32948b1695f329f1ab800ac21a))
*  Oct 10, 2022, 5:41 PM ([8095547](https://gitlab.com/carcheky/raspiserver/commit/80955474f120abce332960dfd0fc090a25af40d2))
*  Oct 10, 2022, 5:57 PM ([9f02782](https://gitlab.com/carcheky/raspiserver/commit/9f027821cbaef515f8b69b49acfaa92f61bf1ea0))
*  Oct 10, 2022, 5:57 PM ([e967b2b](https://gitlab.com/carcheky/raspiserver/commit/e967b2b701e9c02e14b30f282dc268d1713d3ab7))
*  Oct 10, 2022, 5:58 PM ([51c9b57](https://gitlab.com/carcheky/raspiserver/commit/51c9b571f322e3c99ee7e1d4b30ff1cfe02d7b53))
*  Oct 10, 2022, 6:02 PM ([bde5a97](https://gitlab.com/carcheky/raspiserver/commit/bde5a97b05e8e79ffa18721380b293f8158d7f34))
*  Oct 10, 2022, 6:02 PM ([db9f613](https://gitlab.com/carcheky/raspiserver/commit/db9f613df4b33922ea7b46840cbdf8a717deeb6b))
*  Oct 10, 2022, 6:03 PM ([c21d27b](https://gitlab.com/carcheky/raspiserver/commit/c21d27b11a400d5a4c20c0cd5e7ebfb25cc4abdd))
*  Oct 10, 2022, 6:05 PM ([e7c3b66](https://gitlab.com/carcheky/raspiserver/commit/e7c3b668b8a5dd3d3a1b58c50c5c9ea308a957d3))

## [5.0.16](https://gitlab.com/carcheky/raspiserver/compare/v5.0.15...v5.0.16) (2022-10-10)


### Bug Fixes

*  Oct 10, 2022, 5:03 PM ([e2e4825](https://gitlab.com/carcheky/raspiserver/commit/e2e4825f1ebaf470f751f01fd26aec2c6104bf08))
*  Oct 10, 2022, 5:17 PM ([4c5c9d2](https://gitlab.com/carcheky/raspiserver/commit/4c5c9d2ddb35acdc40e433be68a0100f94faf99d))

## [5.0.15](https://gitlab.com/carcheky/raspiserver/compare/v5.0.14...v5.0.15) (2022-10-10)


### Bug Fixes

*  Oct 10, 2022, 4:42 PM ([1752e11](https://gitlab.com/carcheky/raspiserver/commit/1752e11da5a27755f09b689aebb4e38e1d631aeb))

## [5.0.14](https://gitlab.com/carcheky/raspiserver/compare/v5.0.13...v5.0.14) (2022-10-10)


### Bug Fixes

*  Oct 10, 2022, 3:28 PM ([65c6156](https://gitlab.com/carcheky/raspiserver/commit/65c61564c02814c3be0fcefe1249c2236807f7e7))
*  Oct 10, 2022, 3:34 PM ([0912e0a](https://gitlab.com/carcheky/raspiserver/commit/0912e0a8c056c17e7b6114cbbb8495f94d4a4ceb))
*  Oct 10, 2022, 3:35 PM ([7649385](https://gitlab.com/carcheky/raspiserver/commit/76493850c45c18ea5c10faca7d4bb1ad85c4a173))

## [5.0.13](https://gitlab.com/carcheky/raspiserver/compare/v5.0.12...v5.0.13) (2022-10-10)


### Bug Fixes

*  Oct 10, 2022, 1:01 PM ([ed9fd18](https://gitlab.com/carcheky/raspiserver/commit/ed9fd182d99ff56edebc0018d20abe3c40c693c5))
*  Oct 10, 2022, 1:01 PM ([dbfa188](https://gitlab.com/carcheky/raspiserver/commit/dbfa1880e670e6ed0f35c710c5af2b8399f17ffa))
*  Oct 10, 2022, 1:02 PM ([7c7f472](https://gitlab.com/carcheky/raspiserver/commit/7c7f472415922ba5df98287d6ff71d1995eaad89))
*  Oct 10, 2022, 1:02 PM ([3cd8f80](https://gitlab.com/carcheky/raspiserver/commit/3cd8f80814f4116dba3eb3b8b2828c63aaf6dc1c))
*  Oct 10, 2022, 1:03 PM ([9c61d7c](https://gitlab.com/carcheky/raspiserver/commit/9c61d7caad58ae072a3a64a646e97729c2b43943))
*  Oct 10, 2022, 1:03 PM ([ceb1532](https://gitlab.com/carcheky/raspiserver/commit/ceb15329f8d610fcbb6d6e2dc1149ecae8a0d444))
*  Oct 10, 2022, 1:04 PM ([d0eeda1](https://gitlab.com/carcheky/raspiserver/commit/d0eeda1515bc87d038fd3ab74c86bbf53d91f0f7))
*  Oct 10, 2022, 1:04 PM ([0a1c912](https://gitlab.com/carcheky/raspiserver/commit/0a1c912388e8604650d24bd55f218fb81ac06a9b))
*  Oct 10, 2022, 1:05 PM ([2a6354f](https://gitlab.com/carcheky/raspiserver/commit/2a6354f6d9a02b36ae2834b23abfa18aab5c9296))
*  Oct 10, 2022, 1:05 PM ([dd30ca9](https://gitlab.com/carcheky/raspiserver/commit/dd30ca97cecea41185363bf57739d80bd8623e62))
*  Oct 10, 2022, 1:05 PM ([83620f4](https://gitlab.com/carcheky/raspiserver/commit/83620f437a9a30ccd2572a0859f058a741554a92))
*  Oct 10, 2022, 1:05 PM ([75f4dd0](https://gitlab.com/carcheky/raspiserver/commit/75f4dd0cdb6abc316cf4fb6794c57e60f8c4ef16))
*  Oct 10, 2022, 1:06 PM ([1411caf](https://gitlab.com/carcheky/raspiserver/commit/1411caf9195f8b71ee4b0dda03a3692c56896d5b))
*  Oct 10, 2022, 11:26 AM ([78d2843](https://gitlab.com/carcheky/raspiserver/commit/78d2843b859c594beb1db5a4a92a8033b35c3500))
*  Oct 10, 2022, 11:27 AM ([ad10b94](https://gitlab.com/carcheky/raspiserver/commit/ad10b94c21ed2330995ba616a139448ce0773c66))
*  Oct 10, 2022, 11:28 AM ([6c32c11](https://gitlab.com/carcheky/raspiserver/commit/6c32c1183c2e4d29f79b362153c0269a2b6a11d8))
*  Oct 10, 2022, 11:28 AM ([3e7f3b4](https://gitlab.com/carcheky/raspiserver/commit/3e7f3b468ff3ab25f5eae32cfba52c91acacb71a))
*  Oct 10, 2022, 11:29 AM ([9c84c33](https://gitlab.com/carcheky/raspiserver/commit/9c84c33b783ed585f01140ea627de320238788e7))
*  Oct 10, 2022, 11:30 AM ([b4b43cf](https://gitlab.com/carcheky/raspiserver/commit/b4b43cf6ff62a705272ff6d60e89c95d701400ba))
*  Oct 10, 2022, 11:30 AM ([ea9f65f](https://gitlab.com/carcheky/raspiserver/commit/ea9f65f96bd25fcc50c7a9a206c0d4ca0da8a093))
*  Oct 10, 2022, 11:31 AM ([41fb20a](https://gitlab.com/carcheky/raspiserver/commit/41fb20a45b52aff059685e997243c752c89a89e2))
*  Oct 10, 2022, 11:33 AM ([bb6bff8](https://gitlab.com/carcheky/raspiserver/commit/bb6bff85d12e363f1795ec32f9adbf9401705fc7))
*  Oct 10, 2022, 11:33 AM ([69070f3](https://gitlab.com/carcheky/raspiserver/commit/69070f32fabdbac0521f908797af3ae8ee224b15))
*  Oct 10, 2022, 11:37 AM ([6ab6deb](https://gitlab.com/carcheky/raspiserver/commit/6ab6deb859729572187000c4bd3e809bc9824555))
*  Oct 10, 2022, 11:49 AM ([b51e0bd](https://gitlab.com/carcheky/raspiserver/commit/b51e0bdbd5b4653c478da7ad291803ef2d56c476))
*  Oct 10, 2022, 11:51 AM ([1aade86](https://gitlab.com/carcheky/raspiserver/commit/1aade8679c76672c614a815f8c648d6c1c90e92f))
*  Oct 10, 2022, 11:53 AM ([fe1bd97](https://gitlab.com/carcheky/raspiserver/commit/fe1bd9779619e007f8c3958d6973aece7a61340d))
*  Oct 10, 2022, 11:55 AM ([c558972](https://gitlab.com/carcheky/raspiserver/commit/c5589725352f0d4f493cf93b414907f8e7329397))
*  Oct 10, 2022, 11:57 AM ([837a1ba](https://gitlab.com/carcheky/raspiserver/commit/837a1bac714739a241d9acbc927897f16f9552be))
*  Oct 10, 2022, 11:57 AM ([5069e33](https://gitlab.com/carcheky/raspiserver/commit/5069e33cdc1fe22f03799b8c1f4a54394dd4d3d1))
*  Oct 10, 2022, 12:00 PM ([18d53bf](https://gitlab.com/carcheky/raspiserver/commit/18d53bf6492e1c1bfbcf3ea7cf4c08b813d9c2a5))
*  Oct 10, 2022, 12:01 PM ([f6abcd1](https://gitlab.com/carcheky/raspiserver/commit/f6abcd111738d87c1e6655c99335ff021f7ee400))
*  Oct 10, 2022, 12:02 PM ([feccdd4](https://gitlab.com/carcheky/raspiserver/commit/feccdd40979d09c4b01f4370bcd4852ef7ef0aff))
*  Oct 10, 2022, 12:04 PM ([563402a](https://gitlab.com/carcheky/raspiserver/commit/563402a458184bf0931606b24e01ee318875f950))
*  Oct 10, 2022, 12:05 PM ([6d90a95](https://gitlab.com/carcheky/raspiserver/commit/6d90a9580614aa8105193d220ffc0c42d8708e40))
*  Oct 10, 2022, 12:06 PM ([f18190a](https://gitlab.com/carcheky/raspiserver/commit/f18190aa29380a18710f5efe45b9d8e9838e3cf2))
*  Oct 10, 2022, 12:07 PM ([c0eef47](https://gitlab.com/carcheky/raspiserver/commit/c0eef47f210ab91d4042aaac03ccc8731133e3dc))
*  Oct 10, 2022, 12:10 PM ([a7ec4ac](https://gitlab.com/carcheky/raspiserver/commit/a7ec4ac0c7e4baa0d609ab3241756fca75eff850))
*  Oct 10, 2022, 12:10 PM ([4e718b0](https://gitlab.com/carcheky/raspiserver/commit/4e718b09296406796751059edbe07b6dbf69dd92))
*  Oct 10, 2022, 12:14 PM ([879f0af](https://gitlab.com/carcheky/raspiserver/commit/879f0af6acf5a0340ca60a5b9d485cf6073aa6d2))
*  Oct 10, 2022, 12:22 PM ([776b3dc](https://gitlab.com/carcheky/raspiserver/commit/776b3dc999bcdd34de11bbc8e5a16e0f708726eb))
*  Oct 10, 2022, 12:22 PM ([62ec488](https://gitlab.com/carcheky/raspiserver/commit/62ec48809435cea982f9a013c4db5b995661092e))
*  Oct 10, 2022, 12:35 PM ([ebcb6ae](https://gitlab.com/carcheky/raspiserver/commit/ebcb6aea6058d6d9fb90c0792634faa144de4513))
*  Oct 10, 2022, 12:36 PM ([20a3e73](https://gitlab.com/carcheky/raspiserver/commit/20a3e738823c7921012abdc8d37287b478e24e9d))
*  Oct 10, 2022, 12:36 PM ([ac13c8e](https://gitlab.com/carcheky/raspiserver/commit/ac13c8eec6f3495bd46fbe6ef460ab018d5071a1))
*  Oct 10, 2022, 12:36 PM ([34e262b](https://gitlab.com/carcheky/raspiserver/commit/34e262b42c0507b1cf27703b2a1ea7fec0a58864))
*  Oct 10, 2022, 12:37 PM ([2ef1563](https://gitlab.com/carcheky/raspiserver/commit/2ef15636222ab0fec9533decea3b36afd02ee30e))
*  Oct 10, 2022, 12:37 PM ([9771f25](https://gitlab.com/carcheky/raspiserver/commit/9771f25ea5de870d509bb4b50e3400ea762ad4fd))
*  Oct 10, 2022, 12:39 PM ([96298fe](https://gitlab.com/carcheky/raspiserver/commit/96298fea08624dccbe5e3bbf5996f283b83d25f2))
*  Oct 10, 2022, 12:40 PM ([a2b25a4](https://gitlab.com/carcheky/raspiserver/commit/a2b25a4548153ce6e15892b481be93442c3ea84b))
*  Oct 10, 2022, 12:40 PM ([20f270f](https://gitlab.com/carcheky/raspiserver/commit/20f270f89d4df489f5fdc7ddc8c706e123ae7f49))
*  Oct 10, 2022, 12:42 PM ([9b18ea4](https://gitlab.com/carcheky/raspiserver/commit/9b18ea4b47ec56755600fe5707fe02317656cfd6))
*  Oct 10, 2022, 12:50 PM ([fbd6edc](https://gitlab.com/carcheky/raspiserver/commit/fbd6edc64eae6e04b092c888698a7756d0d9efe3))
*  Oct 10, 2022, 12:50 PM ([8ab5aac](https://gitlab.com/carcheky/raspiserver/commit/8ab5aac8a6be23b74a71853a3ecbc1abada468e2))
*  Oct 10, 2022, 12:51 PM ([7d140df](https://gitlab.com/carcheky/raspiserver/commit/7d140dff990fb388ed261e075aa9fba8985aeff5))
*  Oct 10, 2022, 12:52 PM ([8510989](https://gitlab.com/carcheky/raspiserver/commit/8510989e9072c02085a3e22d5674358329c72777))
*  Oct 10, 2022, 12:53 PM ([7600e46](https://gitlab.com/carcheky/raspiserver/commit/7600e4680199125bbe4b888c3aadca83c0950220))
*  Oct 10, 2022, 12:53 PM ([a019cab](https://gitlab.com/carcheky/raspiserver/commit/a019cab8bc2257c601fcbe9e7b8053ae58f4c611))
*  Oct 10, 2022, 12:54 PM ([3fc3380](https://gitlab.com/carcheky/raspiserver/commit/3fc338069d0a9276b4bfdb78b5e8cfb44faf5d11))
*  Oct 10, 2022, 12:54 PM ([eae0fdc](https://gitlab.com/carcheky/raspiserver/commit/eae0fdce67476f97e9dc6430e440bf47cc0dd0fd))
*  Oct 10, 2022, 12:55 PM ([03b7e2e](https://gitlab.com/carcheky/raspiserver/commit/03b7e2e50fcf649fa0f383728b8d9d13158ac8ba))
*  Oct 10, 2022, 12:57 PM ([ab37d45](https://gitlab.com/carcheky/raspiserver/commit/ab37d450a2f4203f45bd0ea83ad485e94a484c78))
*  Oct 10, 2022, 12:57 PM ([f11e29f](https://gitlab.com/carcheky/raspiserver/commit/f11e29f1ed338a18d197c2b5fb2096ffc32e1b51))

## [5.0.12](https://gitlab.com/carcheky/raspiserver/compare/v5.0.11...v5.0.12) (2022-10-10)


### Bug Fixes

*  Oct 10, 2022, 10:37 AM ([14a4bbf](https://gitlab.com/carcheky/raspiserver/commit/14a4bbf455dd9222818c3e61db860a1c70296aed))
*  Oct 10, 2022, 10:40 AM ([b60c0bc](https://gitlab.com/carcheky/raspiserver/commit/b60c0bc5d8149bb65fdbff5319ac44e1510d8740))
*  Oct 10, 2022, 10:42 AM ([808bcdb](https://gitlab.com/carcheky/raspiserver/commit/808bcdba25505c010cb43ff51e31282d57f580c6))
*  Oct 10, 2022, 10:46 AM ([d68e163](https://gitlab.com/carcheky/raspiserver/commit/d68e1639f4da08f63b2c4d78504077ca3d0812c6))

## [5.0.11](https://gitlab.com/carcheky/raspiserver/compare/v5.0.10...v5.0.11) (2022-10-10)


### Bug Fixes

*  Oct 10, 2022, 8:34 AM ([07f6f9f](https://gitlab.com/carcheky/raspiserver/commit/07f6f9f18a25e2a8c17fd94d8e2f7a83a78c5a0b))
*  Oct 10, 2022, 8:34 AM ([a9ca21a](https://gitlab.com/carcheky/raspiserver/commit/a9ca21a8cc8b8f765c2fbefbbd62f9422e4dd3df))
*  Oct 10, 2022, 8:36 AM ([b38ce5f](https://gitlab.com/carcheky/raspiserver/commit/b38ce5f072e5d5ce130e06c7c876c522ceb40518))
*  Oct 10, 2022, 8:42 AM ([b802ae6](https://gitlab.com/carcheky/raspiserver/commit/b802ae6befdf51ad873f24e89625e283c29fcdfd))
*  Oct 10, 2022, 8:45 AM ([cfed0ca](https://gitlab.com/carcheky/raspiserver/commit/cfed0cae1f753bb08b4e31ea6974ea88114c3944))
*  Oct 10, 2022, 8:45 AM ([792ff47](https://gitlab.com/carcheky/raspiserver/commit/792ff47c11f35ee27de0bdd49ac11050e997baad))
*  Oct 10, 2022, 8:49 AM ([4c3cc63](https://gitlab.com/carcheky/raspiserver/commit/4c3cc63f743b4c1e3945791c5308415d0a539798))
*  Oct 10, 2022, 8:53 AM ([e9706aa](https://gitlab.com/carcheky/raspiserver/commit/e9706aae7eaa0d65112a86f39ceced24fded4325))
*  Oct 10, 2022, 8:54 AM ([2775a05](https://gitlab.com/carcheky/raspiserver/commit/2775a05da803e5209cdcc30784fd7f31d6794024))
*  Oct 10, 2022, 8:55 AM ([8d187a3](https://gitlab.com/carcheky/raspiserver/commit/8d187a3d486e5cc607495142f9e518c6c7db7db4))
*  Oct 10, 2022, 8:59 AM ([e08004f](https://gitlab.com/carcheky/raspiserver/commit/e08004ffa5c42082d4afc5e177e1453882b76769))
*  Oct 10, 2022, 9:01 AM ([46c7d96](https://gitlab.com/carcheky/raspiserver/commit/46c7d963ae7a2a73a38c54b762f708a8628b3db0))
*  Oct 10, 2022, 9:07 AM ([61f590e](https://gitlab.com/carcheky/raspiserver/commit/61f590efc35fcf21d3cb4c8ddc63742e222a3f29))
*  Oct 10, 2022, 9:08 AM ([e9d00b1](https://gitlab.com/carcheky/raspiserver/commit/e9d00b1f900450fdb253ef51643a5f947a84fd44))
*  Oct 10, 2022, 9:09 AM ([76ed00e](https://gitlab.com/carcheky/raspiserver/commit/76ed00e6582fc52db63eb3fcd6fc69ae90c4fdd7))
*  Oct 10, 2022, 9:09 AM ([4b341e6](https://gitlab.com/carcheky/raspiserver/commit/4b341e62f31e981515d6e9f52ebe8b34bccc0ec8))
*  Oct 10, 2022, 9:11 AM ([e158027](https://gitlab.com/carcheky/raspiserver/commit/e15802722ae024a78aa1afb130b238c976fb8865))
*  Oct 10, 2022, 9:18 AM ([05ba2a7](https://gitlab.com/carcheky/raspiserver/commit/05ba2a7a8ab672863eafde2ac7b3325e79d2b785))
*  Oct 10, 2022, 9:21 AM ([10c6535](https://gitlab.com/carcheky/raspiserver/commit/10c65359709c6002aee290fdcf00a17616be66f1))
*  Oct 10, 2022, 9:22 AM ([a92ab59](https://gitlab.com/carcheky/raspiserver/commit/a92ab595086d4e0f1076dd99317629fd11457dbe))
*  Oct 10, 2022, 9:22 AM ([5ea0c34](https://gitlab.com/carcheky/raspiserver/commit/5ea0c3442061bb08e63582a0219b3c79e2d1a51b))
*  Oct 10, 2022, 9:27 AM ([3835646](https://gitlab.com/carcheky/raspiserver/commit/383564622e0ff36258ae383d30667c74a7792340))
*  Oct 10, 2022, 9:28 AM ([d4ee47c](https://gitlab.com/carcheky/raspiserver/commit/d4ee47c616b82524e0dcf0b77e00fd0b49cb4f86))
*  Oct 10, 2022, 9:34 AM ([83092d4](https://gitlab.com/carcheky/raspiserver/commit/83092d48cef0b1b3a37da4e7c0fb5f7805d6eaee))
*  Oct 10, 2022, 9:35 AM ([eaadf9a](https://gitlab.com/carcheky/raspiserver/commit/eaadf9aba6f1c5de4bb32efdb9c96947c8534a01))
*  Oct 10, 2022, 9:48 AM ([e74f70a](https://gitlab.com/carcheky/raspiserver/commit/e74f70a8c79513c4161b2d7305344c3fa6c11f5f))
*  Oct 10, 2022, 9:48 AM ([ae1fddc](https://gitlab.com/carcheky/raspiserver/commit/ae1fddc18ed446bad7ea478ee51a73d20062ddc8))
*  Oct 10, 2022, 9:50 AM ([edb4cbc](https://gitlab.com/carcheky/raspiserver/commit/edb4cbc9ff39bd4ef8fa7c1dbec431f6a3399ad6))
*  Oct 10, 2022, 9:50 AM ([d7d4ae2](https://gitlab.com/carcheky/raspiserver/commit/d7d4ae20c8551600c3176afd97b20ce9402e52fb))
*  Oct 10, 2022, 9:51 AM ([b2cb383](https://gitlab.com/carcheky/raspiserver/commit/b2cb383dc8a4925c5acaa3319e86e29e47b7c882))
*  Oct 10, 2022, 9:57 AM ([d951a7c](https://gitlab.com/carcheky/raspiserver/commit/d951a7c4d48e198b24a9ccdab3cb04c899d5b39d))

## [5.0.10](https://gitlab.com/carcheky/raspiserver/compare/v5.0.9...v5.0.10) (2022-10-09)


### Bug Fixes

*  Oct 10, 2022, 1:00 AM ([a32fbb4](https://gitlab.com/carcheky/raspiserver/commit/a32fbb400452dc98f5f5a7106935ed98acc5a941))
*  Oct 10, 2022, 1:00 AM ([e75de4d](https://gitlab.com/carcheky/raspiserver/commit/e75de4df6f2141016e3f9693c8005139c9315831))
*  Oct 10, 2022, 1:06 AM ([3ee19a7](https://gitlab.com/carcheky/raspiserver/commit/3ee19a7e8f9ad8ef5603e52ef9b1788305efbcea))
*  Oct 10, 2022, 1:07 AM ([481d90a](https://gitlab.com/carcheky/raspiserver/commit/481d90a0fc63efad66bc688b877947f7610091a9))
*  Oct 10, 2022, 1:07 AM ([3be97f1](https://gitlab.com/carcheky/raspiserver/commit/3be97f11fad36f8485893d4df8885730c74b221b))
*  Oct 10, 2022, 1:07 AM ([4902bb1](https://gitlab.com/carcheky/raspiserver/commit/4902bb1642cb23641cebbe9342bfa5d916c43980))
*  Oct 10, 2022, 1:07 AM ([0f90744](https://gitlab.com/carcheky/raspiserver/commit/0f90744b77760786f8cbe7a6f2b7afca644ba7ae))
*  Oct 10, 2022, 1:09 AM ([da3c179](https://gitlab.com/carcheky/raspiserver/commit/da3c17992db36d156eaadf91a82dca0f9794c7ab))
*  Oct 10, 2022, 1:09 AM ([c5c6dfe](https://gitlab.com/carcheky/raspiserver/commit/c5c6dfe9d4d316e294f3796afe241c2774425c0f))
*  Oct 10, 2022, 1:10 AM ([3db027e](https://gitlab.com/carcheky/raspiserver/commit/3db027ea0c3b75a2fa6ed88275efcf1717732538))
*  Oct 10, 2022, 1:12 AM ([093a6c7](https://gitlab.com/carcheky/raspiserver/commit/093a6c743af1254c2a9728a4fcc1fc8b8883ddf1))
*  Oct 10, 2022, 1:13 AM ([9427023](https://gitlab.com/carcheky/raspiserver/commit/9427023de684b8bc7d93a3678734597ad47a217f))
*  Oct 10, 2022, 1:15 AM ([f827b63](https://gitlab.com/carcheky/raspiserver/commit/f827b63a6b6022aef1c1e20d2cac47bdbc2be676))
*  Oct 10, 2022, 12:20 AM ([09c1095](https://gitlab.com/carcheky/raspiserver/commit/09c1095b71a13a71eed09598164e324f3eca8a61))
*  Oct 10, 2022, 12:23 AM ([741e244](https://gitlab.com/carcheky/raspiserver/commit/741e244f5718f169b85cde9b61fcafecc49c5cde))
*  Oct 10, 2022, 12:23 AM ([66b4e3e](https://gitlab.com/carcheky/raspiserver/commit/66b4e3e8013b9cb7277d1dd3bdbd051087a2d7ab))
*  Oct 10, 2022, 12:24 AM ([6c5cb9a](https://gitlab.com/carcheky/raspiserver/commit/6c5cb9ad6e7505cee097621c01aa584be46a672c))
*  Oct 10, 2022, 12:25 AM ([b22e379](https://gitlab.com/carcheky/raspiserver/commit/b22e37973df0733677456e23ed8afd27625a14fd))
*  Oct 10, 2022, 12:27 AM ([4ee4647](https://gitlab.com/carcheky/raspiserver/commit/4ee464729da1920ebb97a10ca2437a88ad9ad529))
*  Oct 10, 2022, 12:28 AM ([91498d1](https://gitlab.com/carcheky/raspiserver/commit/91498d13c53e69594f32429ef08e99f218240bf1))
*  Oct 10, 2022, 12:39 AM ([3ecc514](https://gitlab.com/carcheky/raspiserver/commit/3ecc51489b1d86d43fbb8ac11e7bc04ed5b80534))
*  Oct 10, 2022, 12:39 AM ([5afb693](https://gitlab.com/carcheky/raspiserver/commit/5afb6938f7f79e8038ea3a7c56ec709adf6169a4))
*  Oct 10, 2022, 12:42 AM ([050dd4c](https://gitlab.com/carcheky/raspiserver/commit/050dd4c4e133857c7f2501b33f0fd3d1aaafc0d5))
*  Oct 10, 2022, 12:43 AM ([5c5e1db](https://gitlab.com/carcheky/raspiserver/commit/5c5e1dbf2235b16665dc74ab3e2d477d5a977a65))
*  Oct 10, 2022, 12:44 AM ([30b10cf](https://gitlab.com/carcheky/raspiserver/commit/30b10cfbe7c8c66bac74893cf27d2413609dc2e5))
*  Oct 10, 2022, 12:48 AM ([b35a441](https://gitlab.com/carcheky/raspiserver/commit/b35a4419503680c258d2c85ee872866b4fe9c127))
*  Oct 10, 2022, 12:50 AM ([7ba4f65](https://gitlab.com/carcheky/raspiserver/commit/7ba4f65a0970b921c6aec44dce757ecabea6722f))
*  Oct 10, 2022, 12:50 AM ([a477ed8](https://gitlab.com/carcheky/raspiserver/commit/a477ed86a9bced2498c3da4c4caada69ad46f869))
*  Oct 10, 2022, 12:50 AM ([a5bab15](https://gitlab.com/carcheky/raspiserver/commit/a5bab15b84d48d2ca80187ed8cb16aec72858075))
*  Oct 10, 2022, 12:51 AM ([fd33dd4](https://gitlab.com/carcheky/raspiserver/commit/fd33dd47d2024a9f8affb0ad51c22569cf36aba4))
*  Oct 10, 2022, 12:52 AM ([e7b7f10](https://gitlab.com/carcheky/raspiserver/commit/e7b7f1081b7c23e4de847d503d0587b92685234b))
*  Oct 10, 2022, 12:52 AM ([8c0863d](https://gitlab.com/carcheky/raspiserver/commit/8c0863dd855aeef07ad9a1fe069b1d3b0678bb59))
*  Oct 10, 2022, 12:53 AM ([4a9b12b](https://gitlab.com/carcheky/raspiserver/commit/4a9b12b74fa23cf5a3f3cdf3b7bd3dfa08a254d7))
*  Oct 10, 2022, 12:53 AM ([4b50803](https://gitlab.com/carcheky/raspiserver/commit/4b50803f15054965393ddd3f5b9bd411aff6a1f9))
*  Oct 10, 2022, 12:53 AM ([b37e044](https://gitlab.com/carcheky/raspiserver/commit/b37e0445cd25df8d0577d7db8c22646e78456958))
*  Oct 10, 2022, 12:59 AM ([41e67ee](https://gitlab.com/carcheky/raspiserver/commit/41e67ee63d59b86d24a1a89c94c64298ace7dffb))

## [5.0.9](https://gitlab.com/carcheky/raspiserver/compare/v5.0.8...v5.0.9) (2022-10-09)


### Bug Fixes

*  Oct 9, 2022, 10:00 PM ([8627dd0](https://gitlab.com/carcheky/raspiserver/commit/8627dd030d97f7aeb741944d9bae6a17a012f7a1))
*  Oct 9, 2022, 9:06 PM ([5bc08c2](https://gitlab.com/carcheky/raspiserver/commit/5bc08c24fe2aaaf2a39945428e7b3cf76d06aa5d))
*  Oct 9, 2022, 9:06 PM ([c213467](https://gitlab.com/carcheky/raspiserver/commit/c213467447dbd38331d1e9a13911f9b5bf3aff96))
*  Oct 9, 2022, 9:07 PM ([cddb3da](https://gitlab.com/carcheky/raspiserver/commit/cddb3da9d831887120359c27f6a8693b5d4376cb))
*  Oct 9, 2022, 9:13 PM ([fc37224](https://gitlab.com/carcheky/raspiserver/commit/fc37224aa83f3c6e22cbf0a5bc326cc2383f4179))
*  Oct 9, 2022, 9:13 PM ([8aa0569](https://gitlab.com/carcheky/raspiserver/commit/8aa0569300e838fdebd14442fecbc0f2b1a0310d))
*  Oct 9, 2022, 9:15 PM ([4cc419b](https://gitlab.com/carcheky/raspiserver/commit/4cc419b519e9eba213feb3e954cfd56e488c1571))
*  Oct 9, 2022, 9:15 PM ([8f5fd08](https://gitlab.com/carcheky/raspiserver/commit/8f5fd08d552def3e21f33137a5903311d3e7a81d))
*  Oct 9, 2022, 9:15 PM ([680b33b](https://gitlab.com/carcheky/raspiserver/commit/680b33b646f64a2586d6a67a0ccfe3c675280fbc))
*  Oct 9, 2022, 9:16 PM ([6bb01e3](https://gitlab.com/carcheky/raspiserver/commit/6bb01e3183dace2ea8a5d5fd0fec2921bf4049c7))
*  Oct 9, 2022, 9:18 PM ([dab841b](https://gitlab.com/carcheky/raspiserver/commit/dab841ba9f2b0fbc9a78ff66c0ada3e12ca29787))
*  Oct 9, 2022, 9:19 PM ([8465a9b](https://gitlab.com/carcheky/raspiserver/commit/8465a9ba6ebafb680a48bd8c30998889bf91528a))
*  Oct 9, 2022, 9:24 PM ([56040e2](https://gitlab.com/carcheky/raspiserver/commit/56040e2a6593b9cd119d26643005123c75a970d9))
*  Oct 9, 2022, 9:31 PM ([ebdaf21](https://gitlab.com/carcheky/raspiserver/commit/ebdaf219ed13f1c1e7cee986a923ab4358907477))
*  Oct 9, 2022, 9:32 PM ([d5b2398](https://gitlab.com/carcheky/raspiserver/commit/d5b239865f4bf80dca5f5ff616928f74a55c52f5))
*  Oct 9, 2022, 9:36 PM ([bd65ba1](https://gitlab.com/carcheky/raspiserver/commit/bd65ba1422c0c0ec00f36f09ce86ae7cf2378102))
*  Oct 9, 2022, 9:37 PM ([7a24987](https://gitlab.com/carcheky/raspiserver/commit/7a249870bde9324de71177f342a4fe78c7fbdd63))
*  Oct 9, 2022, 9:53 PM ([24b3d8c](https://gitlab.com/carcheky/raspiserver/commit/24b3d8cbad7c5268d942396661ba86157b02ab83))
*  Oct 9, 2022, 9:56 PM ([5f68879](https://gitlab.com/carcheky/raspiserver/commit/5f688792635b2be8c76e839d0a205596f0f2836d))

## [5.0.8](https://gitlab.com/carcheky/raspiserver/compare/v5.0.7...v5.0.8) (2022-10-09)


### Bug Fixes

*  Oct 9, 2022, 7:16 PM ([57ec854](https://gitlab.com/carcheky/raspiserver/commit/57ec854dad9d856d3eaf75824aa3d72f645666c1))
*  Oct 9, 2022, 7:29 PM ([13cab73](https://gitlab.com/carcheky/raspiserver/commit/13cab73bbe18f5d6e51906099959c50311dd5fba))
*  Oct 9, 2022, 7:30 PM ([2d67758](https://gitlab.com/carcheky/raspiserver/commit/2d67758e01a3da947bf19b2bac7845678de7a833))
*  Oct 9, 2022, 7:31 PM ([ec004a8](https://gitlab.com/carcheky/raspiserver/commit/ec004a8013e732a3c4029c8eaf8b4591e9e62ed6))
*  Oct 9, 2022, 7:31 PM ([7f5997a](https://gitlab.com/carcheky/raspiserver/commit/7f5997a31308571dd22fba345e68b8945c835852))
*  Oct 9, 2022, 7:34 PM ([49febe0](https://gitlab.com/carcheky/raspiserver/commit/49febe081403bbad2bcb2564eeffb071280cb3ac))
*  Oct 9, 2022, 7:35 PM ([e09fa00](https://gitlab.com/carcheky/raspiserver/commit/e09fa002b9cd13edd715f4c5e4fc2a651a485ca9))
*  Oct 9, 2022, 7:39 PM ([acb2a33](https://gitlab.com/carcheky/raspiserver/commit/acb2a33dbab2f3ed22162e19fcb8f4d2f8d08487))
*  Oct 9, 2022, 7:44 PM ([3a5c9b3](https://gitlab.com/carcheky/raspiserver/commit/3a5c9b3d65e8c58e67ad482f93933db6ae99e0d2))
*  Oct 9, 2022, 7:46 PM ([2cb556f](https://gitlab.com/carcheky/raspiserver/commit/2cb556f15038fc8f370e479d4eb3ad2197766690))
*  Oct 9, 2022, 7:46 PM ([33015db](https://gitlab.com/carcheky/raspiserver/commit/33015db85863798f96f5e29b05892851564a7c18))
*  Oct 9, 2022, 7:51 PM ([33183da](https://gitlab.com/carcheky/raspiserver/commit/33183dae611fabce40a01336a5cffe0732025c37))
*  Oct 9, 2022, 7:53 PM ([2a5f625](https://gitlab.com/carcheky/raspiserver/commit/2a5f625acd459306e7585f538407d4d82fe5e372))
*  Oct 9, 2022, 7:54 PM ([8dd4962](https://gitlab.com/carcheky/raspiserver/commit/8dd49626bfbf10d680331a98e3634a8f8d4e2bbe))
*  Oct 9, 2022, 8:05 PM ([ba8e01d](https://gitlab.com/carcheky/raspiserver/commit/ba8e01d6ccd13cc1371863fc42334a9b52a7246a))
*  Oct 9, 2022, 8:05 PM ([b9c3b1e](https://gitlab.com/carcheky/raspiserver/commit/b9c3b1e9a1c068e093415c05739f510247c42d95))
*  Oct 9, 2022, 8:05 PM ([8f26aa2](https://gitlab.com/carcheky/raspiserver/commit/8f26aa20dfc9826a461ec08225fb95daf9f65597))
*  Oct 9, 2022, 8:05 PM ([890a42a](https://gitlab.com/carcheky/raspiserver/commit/890a42abb821f65b8dca815454afa636cdf79248))
*  Oct 9, 2022, 8:06 PM ([78f696f](https://gitlab.com/carcheky/raspiserver/commit/78f696fde4856cb6a956c61e765398a599343468))
*  Oct 9, 2022, 8:06 PM ([fe36df1](https://gitlab.com/carcheky/raspiserver/commit/fe36df124489f2c1b1bfce8c8a9e8b74d741cce3))
*  Oct 9, 2022, 8:06 PM ([08b93a1](https://gitlab.com/carcheky/raspiserver/commit/08b93a158733cd21cb5aab05ecbd4dccd1b8832a))
*  Oct 9, 2022, 8:07 PM ([ac38b05](https://gitlab.com/carcheky/raspiserver/commit/ac38b051f5a6b78a9f4301dfc121d07ec46048f1))
*  Oct 9, 2022, 8:07 PM ([3f02961](https://gitlab.com/carcheky/raspiserver/commit/3f02961d4c1b6f31175286d2ae328c8d010d4702))
*  Oct 9, 2022, 8:11 PM ([3c9874d](https://gitlab.com/carcheky/raspiserver/commit/3c9874d16610f19e76602d2a83c76d5a3f8b8354))
*  Oct 9, 2022, 8:13 PM ([df2c46d](https://gitlab.com/carcheky/raspiserver/commit/df2c46ddaa5693205ee62e44599b547704a1205c))
*  Oct 9, 2022, 8:13 PM ([fc8f6b6](https://gitlab.com/carcheky/raspiserver/commit/fc8f6b67b28064afe3439f4e5cfcf531e9f3cf68))
*  Oct 9, 2022, 8:14 PM ([c5dbc2c](https://gitlab.com/carcheky/raspiserver/commit/c5dbc2c5d7bbcfe06c2f3acde2692b9ef908857b))
*  Oct 9, 2022, 8:15 PM ([823f1e2](https://gitlab.com/carcheky/raspiserver/commit/823f1e2bcc3912701a2e0750afa60be00ddff62e))
*  Oct 9, 2022, 8:24 PM ([43f629c](https://gitlab.com/carcheky/raspiserver/commit/43f629caae1f9780b2cbb3e9166eb2ce7394e16d))
*  Oct 9, 2022, 8:26 PM ([0b25ca8](https://gitlab.com/carcheky/raspiserver/commit/0b25ca894d180bbb60a28e3575d58ef204b425cd))
*  Oct 9, 2022, 8:28 PM ([6aafe89](https://gitlab.com/carcheky/raspiserver/commit/6aafe891a27478b1342ec808efb8ff3e7f81e848))
*  Oct 9, 2022, 8:40 PM ([a0828ff](https://gitlab.com/carcheky/raspiserver/commit/a0828ff12e53cbcca475e3fc3afe1ab4d33aedda))
*  Oct 9, 2022, 8:40 PM ([b245e42](https://gitlab.com/carcheky/raspiserver/commit/b245e426d9c0abea8dec505fe928e9c0dc6f66d0))
*  Oct 9, 2022, 8:40 PM ([67f659a](https://gitlab.com/carcheky/raspiserver/commit/67f659a56ac89e932cc5ae9015b7af3700256756))

## [5.0.7](https://gitlab.com/carcheky/raspiserver/compare/v5.0.6...v5.0.7) (2022-10-09)


### Bug Fixes

*  Oct 9, 2022, 4:26 PM ([ab6d0bb](https://gitlab.com/carcheky/raspiserver/commit/ab6d0bb5d0df122660d6d90e67599d1559ad9764))
*  Oct 9, 2022, 4:30 PM ([2effcb5](https://gitlab.com/carcheky/raspiserver/commit/2effcb51e2629e4927bb87005add81711abe8e10))
*  Oct 9, 2022, 4:31 PM ([a5d65ab](https://gitlab.com/carcheky/raspiserver/commit/a5d65ab9253b2503656f79999123935442fc6128))
*  Oct 9, 2022, 4:36 PM ([9202dbb](https://gitlab.com/carcheky/raspiserver/commit/9202dbb06d2a065649a1aec5fc55b95a6cafadea))
*  Oct 9, 2022, 4:37 PM ([ef2e07a](https://gitlab.com/carcheky/raspiserver/commit/ef2e07a125b2f65d27cc8a3e8cc1057d52e708bb))
*  Oct 9, 2022, 4:38 PM ([19b4a49](https://gitlab.com/carcheky/raspiserver/commit/19b4a494e99865dc792578fcad57c44bdec5d727))
*  Oct 9, 2022, 4:40 PM ([3dcd2fc](https://gitlab.com/carcheky/raspiserver/commit/3dcd2fca11c49e3311512846b4a2e6f08c32091d))
*  Oct 9, 2022, 4:42 PM ([57cf664](https://gitlab.com/carcheky/raspiserver/commit/57cf6644ba2146d1cf5844b32df820bd6437c8e5))
*  Oct 9, 2022, 4:43 PM ([aede516](https://gitlab.com/carcheky/raspiserver/commit/aede516ce3d0fb42e9b5090eb17098b45de252a2))
*  Oct 9, 2022, 4:44 PM ([0c6af80](https://gitlab.com/carcheky/raspiserver/commit/0c6af80576af6b8447b497ad6b892f04da6f6211))
*  Oct 9, 2022, 4:44 PM ([e6c3df2](https://gitlab.com/carcheky/raspiserver/commit/e6c3df2d19e0c8d320a998ac99a048626b7e9e73))
*  Oct 9, 2022, 4:45 PM ([5d0190c](https://gitlab.com/carcheky/raspiserver/commit/5d0190c5f0ee0eb03f955d50c8684d52302dfdce))
*  Oct 9, 2022, 4:45 PM ([89404c8](https://gitlab.com/carcheky/raspiserver/commit/89404c81275201c5b44acb425fdc2ce25f00a432))
*  Oct 9, 2022, 4:48 PM ([a9f06c9](https://gitlab.com/carcheky/raspiserver/commit/a9f06c94af45f7f2d17dbd60d8e3f3f59862dce1))
*  Oct 9, 2022, 4:49 PM ([9faf88a](https://gitlab.com/carcheky/raspiserver/commit/9faf88a460155f4f92ca56f2360422404ec6243a))
*  Oct 9, 2022, 4:49 PM ([eb2f784](https://gitlab.com/carcheky/raspiserver/commit/eb2f784a42f04d327e66e3b5f19e85b8d75cc1f8))
*  Oct 9, 2022, 4:50 PM ([5ca14d3](https://gitlab.com/carcheky/raspiserver/commit/5ca14d3bce69cef993bcb9fa602a835dea31aaa0))
*  Oct 9, 2022, 4:50 PM ([f4e03af](https://gitlab.com/carcheky/raspiserver/commit/f4e03af36e80f81bfad9dd9218e96573bdd00f22))
*  Oct 9, 2022, 4:51 PM ([e0732ae](https://gitlab.com/carcheky/raspiserver/commit/e0732ae6e744c4205ae003834f9e338869e961a6))
*  Oct 9, 2022, 4:52 PM ([fa6a90c](https://gitlab.com/carcheky/raspiserver/commit/fa6a90c9a14d72d48ba85934cb7485f53592df8b))
*  Oct 9, 2022, 4:53 PM ([13e09d0](https://gitlab.com/carcheky/raspiserver/commit/13e09d00db7b96277ab158fa2ff85492c603e2fd))
*  Oct 9, 2022, 4:53 PM ([897f75c](https://gitlab.com/carcheky/raspiserver/commit/897f75c1be6a6ab8d64135fb3547aa832c0b83f5))
*  Oct 9, 2022, 4:54 PM ([8298dd9](https://gitlab.com/carcheky/raspiserver/commit/8298dd9aa6486ee881909378542f06cda2411b0f))
*  Oct 9, 2022, 4:55 PM ([226e331](https://gitlab.com/carcheky/raspiserver/commit/226e331947b6eca9b2084c4a07f53ceca119b5e0))
*  Oct 9, 2022, 4:57 PM ([ac65c4b](https://gitlab.com/carcheky/raspiserver/commit/ac65c4bd3d8bb353706b782041157ff4fd098e01))
*  Oct 9, 2022, 4:57 PM ([7c00a8c](https://gitlab.com/carcheky/raspiserver/commit/7c00a8c96e0540b86ec685e3d5af5dd335ac277a))
*  Oct 9, 2022, 4:58 PM ([a80fbdc](https://gitlab.com/carcheky/raspiserver/commit/a80fbdc628961937c8cc47e4cc76f15bbe362986))
*  Oct 9, 2022, 4:58 PM ([bdbd50d](https://gitlab.com/carcheky/raspiserver/commit/bdbd50d4c2847a9b96f39f243d974ecbfb7f0f9a))
*  Oct 9, 2022, 4:59 PM ([dea821d](https://gitlab.com/carcheky/raspiserver/commit/dea821ddbea85dc8b1122d6e0a4b681d36b372f9))
*  Oct 9, 2022, 5:00 PM ([3755976](https://gitlab.com/carcheky/raspiserver/commit/3755976f2bc5276db6eff163f76eb94d901e1bd2))
*  Oct 9, 2022, 5:01 PM ([5d76a4d](https://gitlab.com/carcheky/raspiserver/commit/5d76a4d66affa462af2bfac0a04dfaba9c6d5d05))
*  Oct 9, 2022, 5:02 PM ([e8b30ac](https://gitlab.com/carcheky/raspiserver/commit/e8b30acc0fe6cb310200d4c209de8be6913d4963))
*  Oct 9, 2022, 5:03 PM ([c53bf72](https://gitlab.com/carcheky/raspiserver/commit/c53bf72217d24fa9abf965f43b5d0733954cb9c0))
*  Oct 9, 2022, 5:04 PM ([45389e4](https://gitlab.com/carcheky/raspiserver/commit/45389e41b4953acef886134a758e141abd711495))
*  Oct 9, 2022, 5:06 PM ([cd30c44](https://gitlab.com/carcheky/raspiserver/commit/cd30c44c131aac9d1ea39fb29789bd8e002b74e3))
*  Oct 9, 2022, 5:06 PM ([a9398ae](https://gitlab.com/carcheky/raspiserver/commit/a9398aefdac8fbaebf27e1baf89b00206469c3d0))
*  Oct 9, 2022, 5:07 PM ([d9a7b31](https://gitlab.com/carcheky/raspiserver/commit/d9a7b3185081aa8437bc35f6b6aec7388ff8b329))
*  Oct 9, 2022, 5:08 PM ([2d3e5c9](https://gitlab.com/carcheky/raspiserver/commit/2d3e5c9ad69e1f6c9bf777675a171b55a9c53a6a))
*  Oct 9, 2022, 5:08 PM ([8eab9fb](https://gitlab.com/carcheky/raspiserver/commit/8eab9fbda65a916e1305b170c59d22e27d1a1669))
*  Oct 9, 2022, 5:08 PM ([2201a46](https://gitlab.com/carcheky/raspiserver/commit/2201a46a3264c504d211d1877cfc70cdbc32e00c))
*  Oct 9, 2022, 5:08 PM ([9627956](https://gitlab.com/carcheky/raspiserver/commit/9627956f1ab4b04a232f0e058441575cb89f6cbe))
*  Oct 9, 2022, 5:10 PM ([c384a4c](https://gitlab.com/carcheky/raspiserver/commit/c384a4c5437af1fa580c1cf83a6c5a221ba45675))
*  Oct 9, 2022, 5:11 PM ([4a2bc0b](https://gitlab.com/carcheky/raspiserver/commit/4a2bc0b06af28dee27778a3a57134be5f8fc3cba))
*  Oct 9, 2022, 5:12 PM ([48103c9](https://gitlab.com/carcheky/raspiserver/commit/48103c9111e5372b5826b3196e9bbdeb668f9bc0))
*  Oct 9, 2022, 5:13 PM ([819cb6b](https://gitlab.com/carcheky/raspiserver/commit/819cb6b1a64c9c9625a0a6ec4c1f95535a6d4140))
*  Oct 9, 2022, 5:13 PM ([89f545e](https://gitlab.com/carcheky/raspiserver/commit/89f545e845024a51096255a81a092eabd8d18cab))
*  Oct 9, 2022, 5:14 PM ([8bfcb1a](https://gitlab.com/carcheky/raspiserver/commit/8bfcb1a8171a8b88787b32b4a4d501780b3b95bb))
*  Oct 9, 2022, 5:14 PM ([929ecca](https://gitlab.com/carcheky/raspiserver/commit/929eccaf156bf04ed7146d82656ff9b38599b974))
*  Oct 9, 2022, 5:15 PM ([6d9f2cf](https://gitlab.com/carcheky/raspiserver/commit/6d9f2cf19a545942c02721004126e65b675e6507))
*  Oct 9, 2022, 5:15 PM ([c2252bf](https://gitlab.com/carcheky/raspiserver/commit/c2252bf4d09c10f9d2d7720f563d0aefec8483fa))
*  Oct 9, 2022, 5:15 PM ([8574d24](https://gitlab.com/carcheky/raspiserver/commit/8574d2419dfb2fd672829b1aaa034cb9750812c5))
*  Oct 9, 2022, 5:16 PM ([e8c5007](https://gitlab.com/carcheky/raspiserver/commit/e8c5007f5d22482c31e614ee9cbac4399a4cb47b))
*  Oct 9, 2022, 5:16 PM ([880115d](https://gitlab.com/carcheky/raspiserver/commit/880115dada70087fee468439402999ecf42de4f0))
*  Oct 9, 2022, 5:17 PM ([6b90153](https://gitlab.com/carcheky/raspiserver/commit/6b90153e25bf7b51bb53d4c50a38281b08eb2d1d))
*  Oct 9, 2022, 5:17 PM ([a3abe46](https://gitlab.com/carcheky/raspiserver/commit/a3abe46e8b96e7733de98df8d6629e84957b0765))
*  Oct 9, 2022, 5:19 PM ([b535603](https://gitlab.com/carcheky/raspiserver/commit/b535603786432131211c9ba89e137c9b5d0178ba))
*  Oct 9, 2022, 5:20 PM ([2ebd188](https://gitlab.com/carcheky/raspiserver/commit/2ebd1886e5e9597cf96e3e02c2df1c32cc36ab81))
*  Oct 9, 2022, 5:21 PM ([1207b11](https://gitlab.com/carcheky/raspiserver/commit/1207b117407697a2d68cbc489e42e871eea9daaf))
*  Oct 9, 2022, 5:22 PM ([e10597b](https://gitlab.com/carcheky/raspiserver/commit/e10597b1ca63794313e19662f6f41f2e470798d2))
*  Oct 9, 2022, 5:24 PM ([dcb0602](https://gitlab.com/carcheky/raspiserver/commit/dcb060278511647d55a05f07b217ccc3a2a04637))
*  Oct 9, 2022, 5:24 PM ([7598c58](https://gitlab.com/carcheky/raspiserver/commit/7598c58aa1e6552551c0f961e3cb4dacd2aced4f))
*  Oct 9, 2022, 5:25 PM ([e5374b0](https://gitlab.com/carcheky/raspiserver/commit/e5374b08232787ad68a9a71851162768a91b0763))
*  Oct 9, 2022, 5:26 PM ([c0635bb](https://gitlab.com/carcheky/raspiserver/commit/c0635bbfb17e686c286cc639b465060cdb1fbdd5))
*  Oct 9, 2022, 5:27 PM ([dc2d225](https://gitlab.com/carcheky/raspiserver/commit/dc2d225f35c9d16a01256fc085d55b8da0861458))
*  Oct 9, 2022, 5:27 PM ([809e160](https://gitlab.com/carcheky/raspiserver/commit/809e160c73716eb711bb6c568a5f55bbd5e1d8b8))
*  Oct 9, 2022, 5:28 PM ([5c250cc](https://gitlab.com/carcheky/raspiserver/commit/5c250cc697d4ae31995ede55c93429989546cfcb))
*  Oct 9, 2022, 5:29 PM ([e462f5b](https://gitlab.com/carcheky/raspiserver/commit/e462f5b12318fa6e4745d64892656a95390afdc4))
*  Oct 9, 2022, 5:30 PM ([60e826d](https://gitlab.com/carcheky/raspiserver/commit/60e826dbd96abe870513b48a20a201e50de6681c))
*  Oct 9, 2022, 5:30 PM ([24907d7](https://gitlab.com/carcheky/raspiserver/commit/24907d7f626542ccdee33d8b87d0b05ffa5e3895))
*  Oct 9, 2022, 5:31 PM ([030cc11](https://gitlab.com/carcheky/raspiserver/commit/030cc11ada29b2d70920f4440b19b808701cc2a0))
*  Oct 9, 2022, 5:32 PM ([d6a78db](https://gitlab.com/carcheky/raspiserver/commit/d6a78dbc0ff6177d69fcf711621bf09d5839e180))
*  Oct 9, 2022, 5:34 PM ([3d287f1](https://gitlab.com/carcheky/raspiserver/commit/3d287f163fe2582b6681d1dd379f9f68966bd778))
*  Oct 9, 2022, 5:35 PM ([db14b86](https://gitlab.com/carcheky/raspiserver/commit/db14b86e9942fcacc87009ab014a3b57adf5136d))
*  Oct 9, 2022, 5:38 PM ([8bdf54f](https://gitlab.com/carcheky/raspiserver/commit/8bdf54f39fddc4d5f10f6e0927332e0cfdaeaec3))
*  Oct 9, 2022, 5:38 PM ([b1a239f](https://gitlab.com/carcheky/raspiserver/commit/b1a239faed6f0f430bba20dfc05bfa2ad0d8bfdf))
*  Oct 9, 2022, 5:39 PM ([147f85a](https://gitlab.com/carcheky/raspiserver/commit/147f85a7a22249d2549112d281d61babc4108f01))
*  Oct 9, 2022, 5:42 PM ([fb52cca](https://gitlab.com/carcheky/raspiserver/commit/fb52cca1735064e20214dab1ecc661663533ae21))
*  Oct 9, 2022, 5:42 PM ([5ca7f36](https://gitlab.com/carcheky/raspiserver/commit/5ca7f36ef4ab80cd498243ea75b783b9f9608fad))
*  Oct 9, 2022, 5:42 PM ([8b12846](https://gitlab.com/carcheky/raspiserver/commit/8b12846b29b9e5eddcfe73a1a1d7d415c28c7074))
*  Oct 9, 2022, 5:42 PM ([1a5eba7](https://gitlab.com/carcheky/raspiserver/commit/1a5eba76cc6b80125c48718c72f9d4d023646f54))
*  Oct 9, 2022, 5:43 PM ([063a47b](https://gitlab.com/carcheky/raspiserver/commit/063a47b93ebc5402ead84d2247e4d9fba6338301))
*  Oct 9, 2022, 5:46 PM ([5648896](https://gitlab.com/carcheky/raspiserver/commit/56488966e0c606d66b1bc73fe6a6bb6b8e591ca6))
*  Oct 9, 2022, 5:51 PM ([6a28feb](https://gitlab.com/carcheky/raspiserver/commit/6a28feb5b23fb28371fbaa2f3fca1a6bd45f3c6d))
*  Oct 9, 2022, 5:52 PM ([8997cd9](https://gitlab.com/carcheky/raspiserver/commit/8997cd98a6e9da228498206ca07255848bb29235))
*  Oct 9, 2022, 5:52 PM ([b5a9f39](https://gitlab.com/carcheky/raspiserver/commit/b5a9f399c0d95c779f7a3d88e6897e8b6aaedefc))
*  Oct 9, 2022, 5:56 PM ([aa62c71](https://gitlab.com/carcheky/raspiserver/commit/aa62c71f8361da6aa82d719536b9c52792c9661c))
*  Oct 9, 2022, 5:57 PM ([42264a4](https://gitlab.com/carcheky/raspiserver/commit/42264a4f1276a24ecd58b677c31bd275b51b50aa))
*  Oct 9, 2022, 5:57 PM ([77c7e39](https://gitlab.com/carcheky/raspiserver/commit/77c7e39d46f9dadbdc713fe50b694d00d41981b5))
*  Oct 9, 2022, 5:59 PM ([71a80ee](https://gitlab.com/carcheky/raspiserver/commit/71a80eed405f9c79954872ad36459268e1d0a360))
*  Oct 9, 2022, 6:00 PM ([088d972](https://gitlab.com/carcheky/raspiserver/commit/088d972773271f3f947acaece38162f644ec9c17))

## [5.0.6](https://gitlab.com/carcheky/raspiserver/compare/v5.0.5...v5.0.6) (2022-10-09)


### Bug Fixes

*  Oct 9, 2022, 3:23 PM ([2e9760f](https://gitlab.com/carcheky/raspiserver/commit/2e9760fb1c2b2a310734ba090961dc0a11688548))
*  Oct 9, 2022, 3:24 PM ([fc91ddd](https://gitlab.com/carcheky/raspiserver/commit/fc91ddda19b020909ac94ed62ffc5299592bfefa))
*  Oct 9, 2022, 3:26 PM ([dd6d779](https://gitlab.com/carcheky/raspiserver/commit/dd6d779c31f85b05132e248a6e38739e1e7f8013))
*  Oct 9, 2022, 3:26 PM ([c75941c](https://gitlab.com/carcheky/raspiserver/commit/c75941cbf679d205c47ef27bcc0d0ec5ef2d7148))
*  Oct 9, 2022, 3:27 PM ([f540aad](https://gitlab.com/carcheky/raspiserver/commit/f540aade2f51a5aca722f97bd2a03154c1fa22f3))
*  Oct 9, 2022, 3:36 PM ([821d9ba](https://gitlab.com/carcheky/raspiserver/commit/821d9ba4c2eec477f1b0a5cde046d104a0b523cb))
*  Oct 9, 2022, 3:37 PM ([b7f276e](https://gitlab.com/carcheky/raspiserver/commit/b7f276ea74647951c494907814c2cee2e431246c))
*  Oct 9, 2022, 3:38 PM ([a02132d](https://gitlab.com/carcheky/raspiserver/commit/a02132d5e274e67870051ca42afb93f8a74ffaed))

## [5.0.5](https://gitlab.com/carcheky/raspiserver/compare/v5.0.4...v5.0.5) (2022-10-09)


### Bug Fixes

*  Oct 9, 2022, 1:27 PM ([21937a0](https://gitlab.com/carcheky/raspiserver/commit/21937a041afcb10e13d31853b5d44569f1e8272e))
*  Oct 9, 2022, 1:28 PM ([4db7f98](https://gitlab.com/carcheky/raspiserver/commit/4db7f98afae9efd4bd688912d71ae1690e6d017f))
*  Oct 9, 2022, 1:29 PM ([c337fef](https://gitlab.com/carcheky/raspiserver/commit/c337fef61b8b1caf0508902f946443281cd1cf24))
*  Oct 9, 2022, 1:29 PM ([ab8703c](https://gitlab.com/carcheky/raspiserver/commit/ab8703c54c54b940e20e7b8315a233387f133b7d))
*  Oct 9, 2022, 1:30 PM ([150fd1f](https://gitlab.com/carcheky/raspiserver/commit/150fd1f4caeae74320901d49fdd9d820c389b4a2))
*  Oct 9, 2022, 1:31 PM ([1dec772](https://gitlab.com/carcheky/raspiserver/commit/1dec77288c7ee2a1e2a82a3a17d7002a49f6f26e))
*  Oct 9, 2022, 1:31 PM ([68ccae7](https://gitlab.com/carcheky/raspiserver/commit/68ccae7c6d307a4c6e146428296554dbe15793dc))
*  Oct 9, 2022, 1:32 PM ([e1289b6](https://gitlab.com/carcheky/raspiserver/commit/e1289b660126201e61642af0832a22c576dfceec))
*  Oct 9, 2022, 1:32 PM ([f8b32f1](https://gitlab.com/carcheky/raspiserver/commit/f8b32f1b6b86623a014b27d6b7da8dab57997586))
*  Oct 9, 2022, 1:34 PM ([48470e5](https://gitlab.com/carcheky/raspiserver/commit/48470e513b38590fb84385b2806dd2632fb688cd))
*  Oct 9, 2022, 1:34 PM ([0460dab](https://gitlab.com/carcheky/raspiserver/commit/0460dabf2c04559a54e33cae26e66913be258c64))
*  Oct 9, 2022, 1:35 PM ([0c71ff6](https://gitlab.com/carcheky/raspiserver/commit/0c71ff689e11dbce9c3b69de1835863edc1738df))
*  Oct 9, 2022, 1:35 PM ([0ee8831](https://gitlab.com/carcheky/raspiserver/commit/0ee883161cb05b93b1290e9986cd4bbd8e090a91))
*  Oct 9, 2022, 1:35 PM ([d586147](https://gitlab.com/carcheky/raspiserver/commit/d586147113c955c0bb32131b261e04568f99e63f))
*  Oct 9, 2022, 1:35 PM ([438c1d7](https://gitlab.com/carcheky/raspiserver/commit/438c1d721233291be7edd714da31bf25e8d2ea2a))
*  Oct 9, 2022, 1:36 PM ([1ebc06e](https://gitlab.com/carcheky/raspiserver/commit/1ebc06ea71f09f89a2749fd1a31f5cd91f67277c))
*  Oct 9, 2022, 1:37 PM ([760adb7](https://gitlab.com/carcheky/raspiserver/commit/760adb75f6decb8628dd13ced71858d4e34db8c7))
*  Oct 9, 2022, 1:38 PM ([e42fdca](https://gitlab.com/carcheky/raspiserver/commit/e42fdcaf97cfb17733c32285a2126176df413637))
*  Oct 9, 2022, 1:38 PM ([f2fa2a2](https://gitlab.com/carcheky/raspiserver/commit/f2fa2a293382c47b9fbc8056b140e5007d0b6632))
*  Oct 9, 2022, 1:39 PM ([53f4129](https://gitlab.com/carcheky/raspiserver/commit/53f41298bc1d7d1c03db5a07f9c864da6b0dd9c4))
*  Oct 9, 2022, 1:39 PM ([05f53f7](https://gitlab.com/carcheky/raspiserver/commit/05f53f7c50e7b1b530338232b0943f54087d71f5))
*  Oct 9, 2022, 1:39 PM ([39b7f44](https://gitlab.com/carcheky/raspiserver/commit/39b7f44090f2f131db0f7bb710581a47d452cfcb))
*  Oct 9, 2022, 1:40 PM ([20d0395](https://gitlab.com/carcheky/raspiserver/commit/20d03951c42d220a215d4bb04331b2bdbb733dc5))
*  Oct 9, 2022, 1:40 PM ([ce6c2d3](https://gitlab.com/carcheky/raspiserver/commit/ce6c2d3d1026368a0e22ef06c0df0d906f951612))
*  Oct 9, 2022, 1:40 PM ([5f9fc39](https://gitlab.com/carcheky/raspiserver/commit/5f9fc39647b47e699b7496936b9f55fdd86f1c05))
*  Oct 9, 2022, 1:42 PM ([0dda1a8](https://gitlab.com/carcheky/raspiserver/commit/0dda1a8feef1d257c5c3c18670a9bc307c12e177))
*  Oct 9, 2022, 1:43 PM ([c39298e](https://gitlab.com/carcheky/raspiserver/commit/c39298e1e2ad1ed6c98873cfa6e2830403a60e9d))
*  Oct 9, 2022, 1:46 PM ([c65926e](https://gitlab.com/carcheky/raspiserver/commit/c65926ede325e01dfae7b16136c4b61e921336c9))
*  Oct 9, 2022, 1:47 PM ([85830e8](https://gitlab.com/carcheky/raspiserver/commit/85830e8f0818ba00e59f773e74cdafde38454684))
*  Oct 9, 2022, 1:48 PM ([955a638](https://gitlab.com/carcheky/raspiserver/commit/955a6388722596a1f1ca8511a63dc97aad49cba4))
*  Oct 9, 2022, 1:49 PM ([32393ce](https://gitlab.com/carcheky/raspiserver/commit/32393ce14389bb3d19f68253c6078b9b4cf3f377))
*  Oct 9, 2022, 1:50 PM ([a1f560b](https://gitlab.com/carcheky/raspiserver/commit/a1f560b54442cf24358b24e7bd389b6c4be43b74))
*  Oct 9, 2022, 1:50 PM ([398a228](https://gitlab.com/carcheky/raspiserver/commit/398a228051ea5c1270b0233ad6477a2d27b465d4))
*  Oct 9, 2022, 1:52 PM ([60cf285](https://gitlab.com/carcheky/raspiserver/commit/60cf285299ab6c2068c184735fc79a0903d39d1a))
*  Oct 9, 2022, 1:53 PM ([9d88093](https://gitlab.com/carcheky/raspiserver/commit/9d88093fe331f36d35a3a2510d3285eaaf87be5b))
*  Oct 9, 2022, 1:53 PM ([c1fc432](https://gitlab.com/carcheky/raspiserver/commit/c1fc4325a84ed0e68f348d9612704464e6fb5ced))
*  Oct 9, 2022, 1:54 PM ([5a61542](https://gitlab.com/carcheky/raspiserver/commit/5a6154228880cd51e48f2642eea00733a7c77ecd))
*  Oct 9, 2022, 1:54 PM ([4776c24](https://gitlab.com/carcheky/raspiserver/commit/4776c243f89bf8d599830a23278a05d2bc76fc75))
*  Oct 9, 2022, 2:04 PM ([7451e00](https://gitlab.com/carcheky/raspiserver/commit/7451e005e03ad1bf194d8c7b1b4705fa50bc1aad))
*  Oct 9, 2022, 2:08 PM ([de6e7be](https://gitlab.com/carcheky/raspiserver/commit/de6e7beb509f88977f5ecf25a0037d74e1aba00d))
*  Oct 9, 2022, 2:08 PM ([8c791f3](https://gitlab.com/carcheky/raspiserver/commit/8c791f3f537fbfd67a5b0afc9000c0bf76ac08bf))
*  Oct 9, 2022, 2:09 PM ([60fdfe0](https://gitlab.com/carcheky/raspiserver/commit/60fdfe011c8989960947f858071681efcc4e7c77))
*  Oct 9, 2022, 2:13 PM ([b12596f](https://gitlab.com/carcheky/raspiserver/commit/b12596f2e4fb429eaa85739ef6625d370b4b095b))
*  Oct 9, 2022, 2:13 PM ([ecc6787](https://gitlab.com/carcheky/raspiserver/commit/ecc67879d16563a2511409d05373519dab342132))
*  Oct 9, 2022, 2:14 PM ([d43864c](https://gitlab.com/carcheky/raspiserver/commit/d43864cd08fabb6400c99f61574208658a84775b))
*  Oct 9, 2022, 2:14 PM ([ea675d3](https://gitlab.com/carcheky/raspiserver/commit/ea675d31e247de0222f542de0e399572122cbfbc))
*  Oct 9, 2022, 2:15 PM ([905c470](https://gitlab.com/carcheky/raspiserver/commit/905c470e9dadba5d51d20583f73137d8f99ac467))
*  Oct 9, 2022, 2:16 PM ([2d252c9](https://gitlab.com/carcheky/raspiserver/commit/2d252c9fe67205c428804dd74dfb01d421a71871))
*  Oct 9, 2022, 2:17 PM ([3086f20](https://gitlab.com/carcheky/raspiserver/commit/3086f20fd4eacfb2fd0bfc2f792573cec88bc34e))
*  Oct 9, 2022, 2:18 PM ([f898557](https://gitlab.com/carcheky/raspiserver/commit/f898557d9f264c514d3b2e059a15b4749a478eaf))
*  Oct 9, 2022, 2:21 PM ([c2a2daa](https://gitlab.com/carcheky/raspiserver/commit/c2a2daaf8b1b7872b09abb59df971f0e4a8cb44f))
*  Oct 9, 2022, 2:23 PM ([2d4d1bd](https://gitlab.com/carcheky/raspiserver/commit/2d4d1bdb444ee7fd91883fae6b132ee3074a4c48))
*  Oct 9, 2022, 2:24 PM ([0b2f360](https://gitlab.com/carcheky/raspiserver/commit/0b2f36042771c0e0bcdc8ccdafda4aadcb40d7fb))
*  Oct 9, 2022, 2:25 PM ([eb4071c](https://gitlab.com/carcheky/raspiserver/commit/eb4071cb71d2c3738131b85c474da8edf99a7420))
*  Oct 9, 2022, 2:27 PM ([86bb2eb](https://gitlab.com/carcheky/raspiserver/commit/86bb2eb82798ae7d125df99aee673003bc58303c))
*  Oct 9, 2022, 2:28 PM ([d6416ee](https://gitlab.com/carcheky/raspiserver/commit/d6416ee1ce72c00a9fb590bdeed6f3732dcdedac))
*  Oct 9, 2022, 2:30 PM ([c10fb79](https://gitlab.com/carcheky/raspiserver/commit/c10fb793d4799594fb03725f95b31c71b6c4fa35))
*  Oct 9, 2022, 2:31 PM ([2b3eade](https://gitlab.com/carcheky/raspiserver/commit/2b3eadee25fa97f29143ea9c185285c90f6af5f9))
*  Oct 9, 2022, 2:32 PM ([5a6f8aa](https://gitlab.com/carcheky/raspiserver/commit/5a6f8aaae1dead137f3cba40425e16e3973973ac))
*  Oct 9, 2022, 2:32 PM ([c3ea3f3](https://gitlab.com/carcheky/raspiserver/commit/c3ea3f37bf05c0b61e327f8e0be893ef49846f43))
*  Oct 9, 2022, 2:35 PM ([6d02e7e](https://gitlab.com/carcheky/raspiserver/commit/6d02e7e71dee041893a2f8be3fa82f9e09d2befb))
*  Oct 9, 2022, 2:38 PM ([69d941e](https://gitlab.com/carcheky/raspiserver/commit/69d941e97dd34bcb96414e0a56749560101ceb6e))
*  Oct 9, 2022, 2:40 PM ([eedac89](https://gitlab.com/carcheky/raspiserver/commit/eedac89e37d9d151bcd580f3bd59a56de71b8687))
*  Oct 9, 2022, 2:42 PM ([72ceda8](https://gitlab.com/carcheky/raspiserver/commit/72ceda87b1b931042b2b0eb3d07bb7e003807907))
*  Oct 9, 2022, 2:42 PM ([ac9f30d](https://gitlab.com/carcheky/raspiserver/commit/ac9f30dfc34f05a158b80f734ba1c7a0769bd666))
*  Oct 9, 2022, 2:43 PM ([573b622](https://gitlab.com/carcheky/raspiserver/commit/573b622f8cf32615fa66bab40179dc3b09a9c83f))
*  Oct 9, 2022, 2:43 PM ([7af4e1c](https://gitlab.com/carcheky/raspiserver/commit/7af4e1c61516916a7e480e348c74abddd53aa998))
*  Oct 9, 2022, 2:44 PM ([f5b5c90](https://gitlab.com/carcheky/raspiserver/commit/f5b5c9098b55adc7be033f4c642ca7f3d4923a3f))
*  Oct 9, 2022, 2:45 PM ([fff1a1a](https://gitlab.com/carcheky/raspiserver/commit/fff1a1ae0c3ec262e0d403bf88e9ba5e660bb9aa))
*  Oct 9, 2022, 2:45 PM ([1b43832](https://gitlab.com/carcheky/raspiserver/commit/1b4383236e1b69574ba27badd2437713ab38f732))
*  Oct 9, 2022, 2:46 PM ([644815c](https://gitlab.com/carcheky/raspiserver/commit/644815c90eb4d828d579884d0adf71edbcb94620))
*  Oct 9, 2022, 2:47 PM ([11127c1](https://gitlab.com/carcheky/raspiserver/commit/11127c19b19a1fb896e0194ea8a9f7162f33426a))
*  Oct 9, 2022, 2:47 PM ([3dca46a](https://gitlab.com/carcheky/raspiserver/commit/3dca46aba86d6731d088c303178a00594b88483d))
*  Oct 9, 2022, 2:48 PM ([c2ad5c7](https://gitlab.com/carcheky/raspiserver/commit/c2ad5c71f695d943eb708c4a221701d7560abe86))
*  Oct 9, 2022, 2:50 PM ([0b3f8e2](https://gitlab.com/carcheky/raspiserver/commit/0b3f8e2e7ddf1411b833040593f88f3fd9719a60))
*  Oct 9, 2022, 2:50 PM ([e7cde45](https://gitlab.com/carcheky/raspiserver/commit/e7cde454424111a600fb4b248f2b6b49e84f1bf3))
*  Oct 9, 2022, 2:50 PM ([a8309ea](https://gitlab.com/carcheky/raspiserver/commit/a8309eae907cc2515e9ebcc6b70d4f57872c2d5c))
*  Oct 9, 2022, 2:51 PM ([a4e9d52](https://gitlab.com/carcheky/raspiserver/commit/a4e9d52fd6a80c9e44e8310ad9cb93ae72946992))
*  Oct 9, 2022, 2:51 PM ([1a5441f](https://gitlab.com/carcheky/raspiserver/commit/1a5441fc44732531c3fa72e6f971706d6adc89be))
*  Oct 9, 2022, 2:51 PM ([9b31cde](https://gitlab.com/carcheky/raspiserver/commit/9b31cde4f042617706ad4c269b821036225233c7))
*  Oct 9, 2022, 2:51 PM ([eb95b6d](https://gitlab.com/carcheky/raspiserver/commit/eb95b6d89f188d809beb396691721cbe816acb13))
*  Oct 9, 2022, 2:51 PM ([a3d6649](https://gitlab.com/carcheky/raspiserver/commit/a3d66490559402bc0d9af9c169391e4308970864))
*  Oct 9, 2022, 2:52 PM ([4b00481](https://gitlab.com/carcheky/raspiserver/commit/4b00481b38baeebd165828649bdb9768f11b5c3f))
*  Oct 9, 2022, 2:52 PM ([135e83c](https://gitlab.com/carcheky/raspiserver/commit/135e83c72879f278ebcc50481b9dbc3f240f6e42))
*  Oct 9, 2022, 2:52 PM ([44df0ef](https://gitlab.com/carcheky/raspiserver/commit/44df0ef337df146fadb80372bfd50d0f06fdf753))
*  Oct 9, 2022, 2:52 PM ([695ef16](https://gitlab.com/carcheky/raspiserver/commit/695ef16eaf491a4610c221b0b0e82fef8ccf74ea))
*  Oct 9, 2022, 2:53 PM ([6cf10b6](https://gitlab.com/carcheky/raspiserver/commit/6cf10b6863fab90b8ca88d2d0e2c53dcea449a46))
*  Oct 9, 2022, 2:53 PM ([4c8d954](https://gitlab.com/carcheky/raspiserver/commit/4c8d95471b1469545f9d0e2cd26020d88165e717))
*  Oct 9, 2022, 2:54 PM ([ce3422c](https://gitlab.com/carcheky/raspiserver/commit/ce3422c6541c47b6724464c2c2a0f5cd99a3a9c9))
*  Oct 9, 2022, 2:54 PM ([169f420](https://gitlab.com/carcheky/raspiserver/commit/169f4208e54029d9ef21d59e7ad098e8bec20b41))
*  Oct 9, 2022, 2:54 PM ([6fa658a](https://gitlab.com/carcheky/raspiserver/commit/6fa658abe6934d2a6a4b5cd8b29854bfb49b3dd7))
*  Oct 9, 2022, 2:55 PM ([0f174e4](https://gitlab.com/carcheky/raspiserver/commit/0f174e4e4b11f459c1ad30e54cfbb93a856ef11e))
*  Oct 9, 2022, 2:55 PM ([564266c](https://gitlab.com/carcheky/raspiserver/commit/564266c7bf629fc45401f6e1b2e49e6822c6149c))
*  Oct 9, 2022, 2:55 PM ([b4f54d9](https://gitlab.com/carcheky/raspiserver/commit/b4f54d9ebfeb7ed515a6da92475b7c341cde4cab))
*  Oct 9, 2022, 2:56 PM ([e219a91](https://gitlab.com/carcheky/raspiserver/commit/e219a9172a9643e5d34092d4d4a7699fa58cdc1f))
*  Oct 9, 2022, 2:56 PM ([99e7de9](https://gitlab.com/carcheky/raspiserver/commit/99e7de9de12b5d07101f989bdaac97ceb5ea3a2b))
*  Oct 9, 2022, 2:56 PM ([eb5fa93](https://gitlab.com/carcheky/raspiserver/commit/eb5fa9323294c070cd24fe46dce82762d3aee545))
*  Oct 9, 2022, 2:57 PM ([7b60df3](https://gitlab.com/carcheky/raspiserver/commit/7b60df34d103f9c50206ac7392bc8b51affb5b81))
*  Oct 9, 2022, 2:59 PM ([8e42083](https://gitlab.com/carcheky/raspiserver/commit/8e42083e2a361525660c8e9cd73b5093978c5023))
*  Oct 9, 2022, 2:59 PM ([5e1f6ac](https://gitlab.com/carcheky/raspiserver/commit/5e1f6acfafc5fd4a90e82fe241551ffd3986a0f3))
*  Oct 9, 2022, 3:00 PM ([1778b8e](https://gitlab.com/carcheky/raspiserver/commit/1778b8e8ecf3fab7cbb57be4324972f3095b3861))
*  Oct 9, 2022, 3:00 PM ([72ec023](https://gitlab.com/carcheky/raspiserver/commit/72ec0237f7c5294666b6d63d2c7eec6e16aaf622))
*  Oct 9, 2022, 3:01 PM ([af6243b](https://gitlab.com/carcheky/raspiserver/commit/af6243bab9c09280a3d0417954731ca7c131ca59))
*  Oct 9, 2022, 3:01 PM ([cef420a](https://gitlab.com/carcheky/raspiserver/commit/cef420a8afa8cd3405f332d1901980a6a1bb7c15))
*  Oct 9, 2022, 3:01 PM ([8f933f5](https://gitlab.com/carcheky/raspiserver/commit/8f933f51d128e6c9411b7a683627ebe7223a7217))

## [5.0.4](https://gitlab.com/carcheky/raspiserver/compare/v5.0.3...v5.0.4) (2022-10-09)


### Bug Fixes

*  Oct 9, 2022, 11:14 AM ([a884605](https://gitlab.com/carcheky/raspiserver/commit/a884605619d628ccfbe39d3079035e549520d48c))
*  Oct 9, 2022, 11:17 AM ([8be1606](https://gitlab.com/carcheky/raspiserver/commit/8be160625282f0039eaff8dc56ef38c6d07e16fe))
*  Oct 9, 2022, 11:19 AM ([fb77874](https://gitlab.com/carcheky/raspiserver/commit/fb7787487bc1ed058c8426d0ef5cb714fc16af52))
*  Oct 9, 2022, 11:20 AM ([27bab3e](https://gitlab.com/carcheky/raspiserver/commit/27bab3e4ad6dc58d80b6faafee63a85cadf1561e))
*  Oct 9, 2022, 11:20 AM ([43b05ff](https://gitlab.com/carcheky/raspiserver/commit/43b05ffacff7ed44f10f1d954402321b333b2fad))
*  Oct 9, 2022, 11:22 AM ([86e74e9](https://gitlab.com/carcheky/raspiserver/commit/86e74e94909a98282f6d3220b640dc58e312adda))
*  Oct 9, 2022, 11:22 AM ([2a0e547](https://gitlab.com/carcheky/raspiserver/commit/2a0e547b99a87e3d46aba2a1af8c2e353e2631bb))
*  Oct 9, 2022, 11:23 AM ([f3de4e8](https://gitlab.com/carcheky/raspiserver/commit/f3de4e8c9c06922ab13149b764f7006998d378ed))
*  Oct 9, 2022, 11:25 AM ([6ddb253](https://gitlab.com/carcheky/raspiserver/commit/6ddb2538ec7df0bad35b9fc75e92c9bb93f9ecc7))
*  Oct 9, 2022, 11:27 AM ([15808da](https://gitlab.com/carcheky/raspiserver/commit/15808da11377c976945113e9767a95c82ddf92c6))
*  Oct 9, 2022, 11:28 AM ([be47a67](https://gitlab.com/carcheky/raspiserver/commit/be47a6732ddcabad1035e15cc63a989a1d165367))
*  Oct 9, 2022, 11:28 AM ([1955e6f](https://gitlab.com/carcheky/raspiserver/commit/1955e6f9d3d997ac80709cb5d5fbbafebefde240))
*  Oct 9, 2022, 11:29 AM ([53da647](https://gitlab.com/carcheky/raspiserver/commit/53da647c934e7af6c25bfda590152d89f3e9bd63))
*  Oct 9, 2022, 11:30 AM ([0530c8c](https://gitlab.com/carcheky/raspiserver/commit/0530c8cd0a9bb06291386e543bb0bc271065bcd5))
*  Oct 9, 2022, 11:30 AM ([8b38fb3](https://gitlab.com/carcheky/raspiserver/commit/8b38fb3ab3e6664fa84aff36f1a528713563dfe0))
*  Oct 9, 2022, 11:32 AM ([8c75e65](https://gitlab.com/carcheky/raspiserver/commit/8c75e6546b79feeb6b5b326781c0651ba0373a28))
*  Oct 9, 2022, 11:33 AM ([cd0ac60](https://gitlab.com/carcheky/raspiserver/commit/cd0ac602449872f84e86c69a01afe4bde99e3265))
*  Oct 9, 2022, 11:35 AM ([fc2d898](https://gitlab.com/carcheky/raspiserver/commit/fc2d898491b7ef805d90595be8835af5b01ef354))
*  Oct 9, 2022, 11:36 AM ([a3cbfeb](https://gitlab.com/carcheky/raspiserver/commit/a3cbfeb532bd31c499a6c5b19003e4068867c476))
*  Oct 9, 2022, 11:38 AM ([1a33d22](https://gitlab.com/carcheky/raspiserver/commit/1a33d22b8922ef81a53f2be4d19dbdaf8b71b3e8))
*  Oct 9, 2022, 11:38 AM ([0e993f3](https://gitlab.com/carcheky/raspiserver/commit/0e993f3137f8194ef08763a2fd3bbb9055298ea8))
*  Oct 9, 2022, 11:39 AM ([80f8c31](https://gitlab.com/carcheky/raspiserver/commit/80f8c31013482358f06c35240336093970ecf3eb))
*  Oct 9, 2022, 11:41 AM ([7a01ee9](https://gitlab.com/carcheky/raspiserver/commit/7a01ee907b91362cf194acc64caa954823c15823))
*  Oct 9, 2022, 11:45 AM ([6c1bd43](https://gitlab.com/carcheky/raspiserver/commit/6c1bd43d100790cfd7434d9727d89f56b0e58370))
*  Oct 9, 2022, 11:46 AM ([9f3502e](https://gitlab.com/carcheky/raspiserver/commit/9f3502e6a0322c7dc4d9b32dd14307454d70c24d))
*  Oct 9, 2022, 11:46 AM ([f4e5500](https://gitlab.com/carcheky/raspiserver/commit/f4e55009a44eb35602568c3fdf9982d015c16e83))
*  Oct 9, 2022, 11:47 AM ([8667519](https://gitlab.com/carcheky/raspiserver/commit/8667519659e911711b7231762ae77170a9e6baa1))
*  Oct 9, 2022, 11:47 AM ([2851a93](https://gitlab.com/carcheky/raspiserver/commit/2851a93ef464a28e228b3378031cbd1234680a99))
*  Oct 9, 2022, 11:49 AM ([d1b518b](https://gitlab.com/carcheky/raspiserver/commit/d1b518bd608ff2c32f880a14a225286a843fa447))
*  Oct 9, 2022, 11:50 AM ([fe23985](https://gitlab.com/carcheky/raspiserver/commit/fe23985de0f806dac468b6a7586e80881e2d97b2))
*  Oct 9, 2022, 11:51 AM ([2440fbf](https://gitlab.com/carcheky/raspiserver/commit/2440fbf188222d858159c8791b27641ecbfaf1db))
*  Oct 9, 2022, 11:51 AM ([b525aca](https://gitlab.com/carcheky/raspiserver/commit/b525acac45b416190bc7f27b7bb707c7c0803ff4))
*  Oct 9, 2022, 11:52 AM ([4aac8f4](https://gitlab.com/carcheky/raspiserver/commit/4aac8f4d2957be3b6fc7eaa7e29b59cae80c900e))
*  Oct 9, 2022, 11:54 AM ([22d2938](https://gitlab.com/carcheky/raspiserver/commit/22d29384b32f8462586acd582869824d3d3682a2))
*  Oct 9, 2022, 11:55 AM ([a659cd2](https://gitlab.com/carcheky/raspiserver/commit/a659cd2efbb8ff94e979465db51873e1c20fac2b))
*  Oct 9, 2022, 11:56 AM ([5772ceb](https://gitlab.com/carcheky/raspiserver/commit/5772ceb25be04a2011e8e5f563be1b11b3df2d35))
*  Oct 9, 2022, 11:59 AM ([c7737f8](https://gitlab.com/carcheky/raspiserver/commit/c7737f842c9903af1bb310b9587b25b8523c272d))
*  Oct 9, 2022, 12:00 PM ([cdae4af](https://gitlab.com/carcheky/raspiserver/commit/cdae4af8703800647c0637cf88d05e22017fe94b))
*  Oct 9, 2022, 12:00 PM ([16eb81a](https://gitlab.com/carcheky/raspiserver/commit/16eb81ab057419bb63c60b9841240d33a1479871))
*  Oct 9, 2022, 12:04 PM ([2a04988](https://gitlab.com/carcheky/raspiserver/commit/2a0498815999068787fb122acab3a6a32f8d497b))
*  Oct 9, 2022, 12:06 PM ([14b25dd](https://gitlab.com/carcheky/raspiserver/commit/14b25dd8b9faaa3f3a0b9ed7b56f9e8ea23656d9))
*  Oct 9, 2022, 12:06 PM ([7ceb056](https://gitlab.com/carcheky/raspiserver/commit/7ceb056ccbe079a47eb43ecc76174947ad6a0d28))
*  Oct 9, 2022, 12:06 PM ([e3fde46](https://gitlab.com/carcheky/raspiserver/commit/e3fde46d02c9b5f75f88877bf543b1bb104b11a4))
*  Oct 9, 2022, 12:07 PM ([f5cf0e9](https://gitlab.com/carcheky/raspiserver/commit/f5cf0e912434893758bbdd49c94512f59f5a5f01))
*  Oct 9, 2022, 12:07 PM ([34d37ad](https://gitlab.com/carcheky/raspiserver/commit/34d37ada38625f344a2d97e4eedb35d642cafd05))
*  Oct 9, 2022, 12:07 PM ([3c88eab](https://gitlab.com/carcheky/raspiserver/commit/3c88eab8787c696bdd006410565502d6f82b1432))
*  Oct 9, 2022, 12:09 PM ([f0bf213](https://gitlab.com/carcheky/raspiserver/commit/f0bf2137cad193d116fb544361bb45e57931131a))
*  Oct 9, 2022, 12:10 PM ([6e0f350](https://gitlab.com/carcheky/raspiserver/commit/6e0f350d1b02e1609b0b2aeb95bc175c341e7305))
*  Oct 9, 2022, 12:12 PM ([a6af353](https://gitlab.com/carcheky/raspiserver/commit/a6af353755f49637602981a027171f1d9b258cf0))
*  Oct 9, 2022, 12:13 PM ([22e27e2](https://gitlab.com/carcheky/raspiserver/commit/22e27e2e4dab6da8672220cdd451374f24d0953f))
*  Oct 9, 2022, 12:16 PM ([5f68385](https://gitlab.com/carcheky/raspiserver/commit/5f683854f6769303e61e2a6276f91a205b5d739d))
*  Oct 9, 2022, 12:18 PM ([3fb2c53](https://gitlab.com/carcheky/raspiserver/commit/3fb2c535c5e20fefe4eb243a0eff467cc729268d))
*  Oct 9, 2022, 12:22 PM ([7ea1bb4](https://gitlab.com/carcheky/raspiserver/commit/7ea1bb4a69ccaec1e7a3ead31286885026091f3f))

## [5.0.3](https://gitlab.com/carcheky/raspiserver/compare/v5.0.2...v5.0.3) (2022-10-09)


### Bug Fixes

*  Oct 9, 2022, 10:49 AM ([2bae519](https://gitlab.com/carcheky/raspiserver/commit/2bae519fe4acced61021e71cefbf33f6197b0d41))
*  Oct 9, 2022, 10:51 AM ([c3a5845](https://gitlab.com/carcheky/raspiserver/commit/c3a5845360d4f08f04f65ee6e5c8f6be06dc8614))
*  Oct 9, 2022, 10:52 AM ([c336072](https://gitlab.com/carcheky/raspiserver/commit/c336072efeb2f610df45d823a37540ba85051d62))
*  Oct 9, 2022, 10:52 AM ([62b3e13](https://gitlab.com/carcheky/raspiserver/commit/62b3e133014ba9d2e640e2c478468c471b066cd8))
*  Oct 9, 2022, 10:54 AM ([0238456](https://gitlab.com/carcheky/raspiserver/commit/0238456f2c42ca8bdf56e1f4adeaf1ac328557ba))
*  Oct 9, 2022, 10:57 AM ([f75e0d7](https://gitlab.com/carcheky/raspiserver/commit/f75e0d7c76af2647e4ef3e8d8e2c74e1d51d1dfb))
*  Oct 9, 2022, 10:58 AM ([cbcda2d](https://gitlab.com/carcheky/raspiserver/commit/cbcda2dba8b9336869706180a917c6af6828a73f))
*  Oct 9, 2022, 11:00 AM ([1aba882](https://gitlab.com/carcheky/raspiserver/commit/1aba88271eb5bfb54243fd2a46d43e2e1a0bfc6e))
*  Oct 9, 2022, 11:00 AM ([9d9f8c7](https://gitlab.com/carcheky/raspiserver/commit/9d9f8c714e1825f0a7f6c9bc710110c500843f3c))
*  Oct 9, 2022, 11:02 AM ([a5d6010](https://gitlab.com/carcheky/raspiserver/commit/a5d6010fc684275eef7e36ff1d18670c872a8445))
*  Oct 9, 2022, 11:02 AM ([95a8c51](https://gitlab.com/carcheky/raspiserver/commit/95a8c514f333c9fb6e43a8b65a306b22e1f1d069))
*  Oct 9, 2022, 11:03 AM ([9e3b5ad](https://gitlab.com/carcheky/raspiserver/commit/9e3b5addd77636899b4ab834306859b9297ccb92))
*  Oct 9, 2022, 11:04 AM ([df98219](https://gitlab.com/carcheky/raspiserver/commit/df982191e7d72ac4b146b743463935774e4e8ffb))
*  Oct 9, 2022, 11:04 AM ([c81933f](https://gitlab.com/carcheky/raspiserver/commit/c81933f8f14f934fa858c879b0e4035427bef3cb))
*  Oct 9, 2022, 11:05 AM ([d0cec7d](https://gitlab.com/carcheky/raspiserver/commit/d0cec7dc1948f2a30fbf6d967cc8cbc48c4d6a48))
*  Oct 9, 2022, 11:07 AM ([4f28542](https://gitlab.com/carcheky/raspiserver/commit/4f285426e065fe930565083b0fc698c66da0ef7a))

## [5.0.2](https://gitlab.com/carcheky/raspiserver/compare/v5.0.1...v5.0.2) (2022-10-08)


### Bug Fixes

*  Oct 8, 2022, 3:50 PM ([26d8553](https://gitlab.com/carcheky/raspiserver/commit/26d85537f1d601e93af68f5bf041938c786512cb))
*  Oct 8, 2022, 3:51 PM ([4aa63c1](https://gitlab.com/carcheky/raspiserver/commit/4aa63c1e61301970fd11fc0fbbf407d417c83cd7))
*  Oct 8, 2022, 3:53 PM ([004ad76](https://gitlab.com/carcheky/raspiserver/commit/004ad76f7a9aeaa60dea04b0e052bd47f799b418))
*  Oct 8, 2022, 3:53 PM ([401c269](https://gitlab.com/carcheky/raspiserver/commit/401c269055d1b4f8c6aab6b1822bccd085fc7bab))
*  Oct 8, 2022, 3:54 PM ([8645728](https://gitlab.com/carcheky/raspiserver/commit/864572844bc76f5b93e1dcd03f38af67d024a47b))
*  Oct 8, 2022, 3:54 PM ([dee2b8e](https://gitlab.com/carcheky/raspiserver/commit/dee2b8e93936af652dacc5f8f3a2abb0ba71bcdf))
*  Oct 8, 2022, 3:54 PM ([ea8c0ff](https://gitlab.com/carcheky/raspiserver/commit/ea8c0ff7826857db4aff5ddd4e661a3ba557f3ab))
*  Oct 8, 2022, 3:56 PM ([272bcdc](https://gitlab.com/carcheky/raspiserver/commit/272bcdc11a606809ba8088cec8254cffeef03a7f))
*  Oct 8, 2022, 3:59 PM ([19e00d2](https://gitlab.com/carcheky/raspiserver/commit/19e00d2e574f35d280364bee8514d43627f11e9f))
*  Oct 8, 2022, 4:00 PM ([1aa6e7e](https://gitlab.com/carcheky/raspiserver/commit/1aa6e7e8d19d8517d180beaa73924e0e1cf7fe2b))
*  Oct 8, 2022, 4:02 PM ([f937b8c](https://gitlab.com/carcheky/raspiserver/commit/f937b8c655b20352410792bc6988f8d1a5cc408d))
*  Oct 8, 2022, 4:03 PM ([2c9d0f1](https://gitlab.com/carcheky/raspiserver/commit/2c9d0f15e8973b8d913f29c256d780bfc3bf2b53))
*  Oct 8, 2022, 4:04 PM ([1df8974](https://gitlab.com/carcheky/raspiserver/commit/1df897433b0177c0ee4bb9b2784a33b76247ec22))
*  Oct 8, 2022, 4:05 PM ([4facfbc](https://gitlab.com/carcheky/raspiserver/commit/4facfbc8022bdd3d49bcdf1ea0fc6fa45091fe05))
*  Oct 8, 2022, 4:06 PM ([e3828a3](https://gitlab.com/carcheky/raspiserver/commit/e3828a3395d6c963d386f34e7a31e69837bfa7ac))

## [5.0.1](https://gitlab.com/carcheky/raspiserver/compare/v5.0.0...v5.0.1) (2022-10-08)


### Bug Fixes

*  Oct 8, 2022, 3:18 PM ([198df77](https://gitlab.com/carcheky/raspiserver/commit/198df7720c879fe627b6396218ae10e26498db32))
*  Oct 8, 2022, 3:20 PM ([abdc87e](https://gitlab.com/carcheky/raspiserver/commit/abdc87eb48d3f339dfbbf19407360da886d9fcaf))
*  Oct 8, 2022, 3:22 PM ([1f208fe](https://gitlab.com/carcheky/raspiserver/commit/1f208fe114e5bf13d9841e6176d0febd5570586f))
*  Oct 8, 2022, 3:24 PM ([f42bc76](https://gitlab.com/carcheky/raspiserver/commit/f42bc7659d1d70399beed71f4570208c0564d79c))
*  Oct 8, 2022, 3:26 PM ([804be54](https://gitlab.com/carcheky/raspiserver/commit/804be5470fd18dc8a80c222b8fad39123a8eab21))
*  Oct 8, 2022, 3:26 PM ([1b17764](https://gitlab.com/carcheky/raspiserver/commit/1b177646df89914baa062892a9d145e573ec8abd))
*  Oct 8, 2022, 3:30 PM ([32466eb](https://gitlab.com/carcheky/raspiserver/commit/32466ebd287a78549cff3050ab83509c39a56b50))
*  Oct 8, 2022, 3:31 PM ([761abb1](https://gitlab.com/carcheky/raspiserver/commit/761abb169b6ae01e7d685e9f8b883e232c1f4d34))
*  Oct 8, 2022, 3:31 PM ([bf134e1](https://gitlab.com/carcheky/raspiserver/commit/bf134e1c34537d07f7d3344ec4a9cc6b01865cf3))
*  Oct 8, 2022, 3:34 PM ([7312f5b](https://gitlab.com/carcheky/raspiserver/commit/7312f5badc2b32358884f1a36e779982a4127149))
*  Oct 8, 2022, 3:38 PM ([3e1b827](https://gitlab.com/carcheky/raspiserver/commit/3e1b8274b4307ff77e2e5f068832c1095e08d758))
*  Oct 8, 2022, 3:40 PM ([945c804](https://gitlab.com/carcheky/raspiserver/commit/945c8040b3eb6cce8996f1c691b30173ce012d0c))
