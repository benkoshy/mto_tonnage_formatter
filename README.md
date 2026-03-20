### Publishing

When you want to publish:

```sh
mise use node@8
elm-app build
mise use node@18
gh-pages -d build
```


### Development

But when you want to develop:

```sh
mise use node@8
elm-app start
```
