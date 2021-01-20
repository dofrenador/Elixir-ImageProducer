defmodule Identicon do
  def main (input) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
    |> filter_odd()
    |> build_pixel_map()
    |> draw_image()
    |> save_image(input)
  end

  def save_image(image,input) do
    File.write("#{input}.png",image)

  end
  def draw_image(%Identicon.Image{colors: colors, pixel_map: pixel_map}) do

    #we will use erlang functions here

    image = :egd.create(250,250)
    fill = :egd.color(colors)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image,start,stop,fill)
    end

    :egd.render(image)

  end
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizantal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizantal, vertical}
      bottom_right = { horizantal + 50, vertical + 50}
      {top_left, bottom_right}
    end
    %Identicon.Image{image | pixel_map: pixel_map}
  end
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid = hex
    |> Enum.chunk(3)
    |> Enum.map(&mirrow_row/1)
    |> List.flatten()
    |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  def filter_odd(%Identicon.Image{grid: grid} = image) do

    grid = Enum.filter grid, fn({code,_index}) ->
      rem(code,2) == 0
    end
    %Identicon.Image{image | grid: grid}
  end


  def mirrow_row(row) do
    # [145, 67, 200] ----> [145,67,200,67,145]
    [first,second | _tail] = row
    row ++ [second,first]


  end
  def pick_color(%Identicon.Image{hex: [r,g,b | _tail]} = image) do #Pattern mathcing happens in the argument!
    %Identicon.Image{image | colors: {r,g,b}}
    #[r,g,b]
  end

  # OOP WAY OF PİCK COLOR
  # pickColor: fnc(image){
  #   image.color = {
  #     r: image.hex[0],
  #     g: image.hex[1],
  #     b: image.hex[2]
  #   };

  #   return image
  # }

  def hash_input(input) do #crates an arbitrary list of size 16 in the range of 0-255(perfect for rgb)
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end
end
