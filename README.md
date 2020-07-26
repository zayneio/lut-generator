# Lookup Table Generator
Create Lookup Tables (LUTs) from images.

I wrote this script so that I could take Adobe LightRoom settings, convert them into lookup tables, and use them to color grade videos. It should work for other things as well though.

The basic idea is that you can feed this program the path to your image file containing your color settings and it will generate a Lookup Table and store it in a new .cube file in the current directory.

For example, if your file's name is `hald.jpg`, then this script will create a new LUT titled `hald.cube`

### Example
```ruby
require './lut_generator'

LUTGenerator.create_lut('path/to/your/image')
```


## How it works
Before generating a Lookup Table, you'll need to create a HALD image that you can use to apply your color settings to. You can use the method in this class if you'd like:
```ruby
  LUTGenerator.create_hald
```
This method is just a thin wrapper around an ImageMagick command to create a new hald file:
```shell
convert hald:8 hald.jpg
```

This will create a 512x512 jpg. You can adjust this as well. For example, this will create a 125x125 png:
```ruby
  LUTGenerator.create_hald(5, 'png')
```

Once you have a hald image, you can add it into Adobe LightRoom, apply your color settings onto it, and export the image with the effects. This is the file you'll run through `LUTGenerator#create_lut` to create your LUT.

At this point, all you should need to do is trigger the call method, passing in the path to your image file:
```ruby
  LUTGenerator.create_lut('path/to/your/image')
```

Check in the current directory after running this and you should now have a new LUT file with a .cube extension. You can now take this file and use it to color grade your images and videos!

### Dependencies
This code is dependent on ImageMagick and the ruby gem RMagick.

Install ImageMagick:
```shell
brew install imagemagick
```

Install RMagick:
```shell
gem install rmagick
```
