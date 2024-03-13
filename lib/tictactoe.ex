defmodule Tictactoe do
  use Application
  alias TableRex

  @title "
  ╦ ╦╔═╗╦  ╔═╗╔═╗╔╦╗╔═╗  ╔╦╗╔═╗
  ║║║║╣ ║  ║  ║ ║║║║║╣    ║ ║ ║
  ╚╩╝╚═╝╩═╝╚═╝╚═╝╩ ╩╚═╝   ╩ ╚═╝
    ╔╦╗╦╔═╗╔╦╗╔═╗╔═╗╔╦╗╔═╗╔═╗
     ║ ║║───║ ╠═╣║───║ ║ ║║╣
     ╩ ╩╚═╝ ╩ ╩ ╩╚═╝ ╩ ╚═╝╚═╝
-----------------------------------"

  def start(_type, _args) do
    Tictactoe.main()
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def main do
    IO.puts(@title)

    internal_gridmap = %{
      a0: :-,
      a1: :-,
      a2: :-,
      b0: :-,
      b1: :-,
      b2: :-,
      c0: :-,
      c1: :-,
      c2: :-
    }
    IO.inspect(internal_gridmap)
    grid = TableRex.Table.new(convert_map_to_grid(internal_gridmap))
    grid = TableRex.Table.put_column_meta(grid, :all, color: &Tictactoe.decide_color/2, padding: 4)
    grid = TableRex.Table.put_column_meta(grid, 3, padding: 1)
    IO.puts(TableRex.Table.render!(grid, horizontal_style: :all, intersection_symbol: "•"))

    internal_gridmap = ask_for_coordinates(internal_gridmap)

    grid = TableRex.Table.clear_rows(grid)
    IO.inspect(grid)
    IO.inspect(internal_gridmap)
    grid = TableRex.Table.add_rows(grid, convert_map_to_grid(internal_gridmap))
    IO.puts(TableRex.Table.render!(grid, horizontal_style: :all, intersection_symbol: "•"))
  end

  def decide_color(text, value) do
    case value do
      "-" -> [:white, text]
      "x" -> [:red, text]
      "o" -> [:green, text]
      _ -> text
    end
  end

  def convert_map_to_grid(map) do
    [
      [:a, :b, :c, "☺"],
      [map.a0, map.b0, map.c0, 0],
      [map.a1, map.b1, map.c1, 1],
      [map.a2, map.b2, map.c2, 2]
    ]
  end

  def ask_for_coordinates(map) do
    coord_input = String.trim(IO.gets("Insert coordinates (ex: a0, b1, c2...): "), "\n")

    if Map.has_key?(map, String.to_existing_atom(coord_input)) do
      ask_for_value(map, String.to_existing_atom(coord_input))
    else
      ask_for_coordinates(map)
    end
  end

  def ask_for_value(map, coordinate) do
    value_input = String.trim(IO.gets("Insert x or o: "), "\n")
    if value_input === "x" or value_input === "o" do
      Map.replace!(map, coordinate, value_input)
    else
      ask_for_value(map, coordinate)
    end
  end
end
