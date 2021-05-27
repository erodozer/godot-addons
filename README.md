# godot-addons

A collection of general purpose addons I've written over time while messing around with Godot.  These addons have been organized in a way that leverages npm packages so they may easily be included in your godot projects.  This is an alternative pattern to using the Asset store or cloning git repositories and layering them onto your project.

## How To Use

If you're not familiar with npm and github registries, it may be a good starting point to [read this guide](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry)

If you have npm installed, in your godot project simply run `npm init` to ready it for installing packages.  From there, you'll need to create an `.npmrc` file at the root directory of your project.  Within it, we will reference the OWNER scope of these godot packages to the github registry that they're on.  

The main repository packages are published at the following

```
# .npmrc

# godot modules from github
@nhydock:registry=https://npm.pkg.github.com/nhydock
```

Once you have followed the instructions for authenticating and being able to read packages from the registry, you can start to install the packages using npm.  After installing the packages that you want for your project, your package.json will look something similar to this

```
{
  "name": "adventure",
  "version": "1.0.0",
  "main": "project.godot",
  "license": "ISC",
  "private": true,
  "dependencies": {
    "@nhydock/godot-pausestack": "^1.0.2",
    "@nhydock/godot-screenshot": "^1.0.1",
    "@nhydock/godot-ssm": "^1.0.1",
    "@nhydock/godot-tonemapper": "^1.1.0"
  }
}
```

Npm installs addons into the `node_modules/` folder.  Unfortunately this is not configurable.  This means referencing files will look something like

```
[autoload]

Pause="*res://node_modules/@nhydock/godot-pausestack/Pause.gd"
ToneMap="*res://node_modules/@nhydock/godot-tonemapper/ToneMapper.tscn"
Screenshot="*res://node_modules/@nhydock/godot-screenshot/screenshot.gd"
SceneManager="*res://node_modules/@nhydock/godot-ssm/SceneManager.tscn"
```

## Best Practices

As these are packages managed by a third-party, when using a package manager like npm you should consider the contents of the package to be immutable.  If you wish to configure any of the scenes or modify code, you should create new ones that inherit from the base version in the dependency.  This makes it safe and easy to upgrade packages.  

Npm respects semantic versiong when upgrading.  Packages in this repository should adhere to incrementing version numbers with respect to the impact it will have on end users who upgrade.  

eg. when the main file of a package is renamed, or its API changes an existing function in a breaking way, that should be a major version adjustment

### Reference

* [Godot Engine](https://godotengine.org/)
* [Proposal about Godot Package Management](https://github.com/godotengine/godot-proposals/issues/62)
* [NPM](https://www.npmjs.com/)
* [Working with Github NPM Package Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry)
