defmodule Tictactoe do
  use Application
  alias TableRex

  @title_art "
  ╦ ╦╔═╗╦  ╔═╗╔═╗╔╦╗╔═╗  ╔╦╗╔═╗
  ║║║║╣ ║  ║  ║ ║║║║║╣    ║ ║ ║
  ╚╩╝╚═╝╩═╝╚═╝╚═╝╩ ╩╚═╝   ╩ ╚═╝
    ╔╦╗╦╔═╗╔╦╗╔═╗╔═╗╔╦╗╔═╗╔═╗
     ║ ║║───║ ╠═╣║───║ ║ ║║╣
     ╩ ╩╚═╝ ╩ ╩ ╩╚═╝ ╩ ╚═╝╚═╝
-----------------------------------"

  # Backslashes in ASCII art had to be escaped, so it looks a little weird here
  # Here is what everything would look like on the console

  #                                         __  __
  #                                         \•\/•/ ∩
  #                                         /\  /_/
  #                                        U /  \
  #                                         /_/\_\
  #                                         //  \\
  #                                       (__)  (__)
  #  ___   _      __    _     ____  ___       ___   _      ____      _       _   _      __
  # | |_) | |    / /\  \ \_/ | |_  | |_)     / / \ | |\ | | |_      \ \    /| | | |\ | ( (`
  # |_|   |_|__ /_/--\  |_|  |_|__ |_| \     \_\_/ |_| \| |_|__      \_\/\/ |_| |_| \| _)_)

  @x_winner_art "
                                        __  __
                                        \\•\\/•/ ∩
                                        /\\  /_/
                                       U /  \\
                                        /_/\\_\\
                                        //  \\\\
                                      (__)  (__)
 ___   _      __    _     ____  ___       ___   _      ____      _       _   _      __
| |_) | |    / /\\  \\ \\_/ | |_  | |_)     / / \\ | |\\ | | |_      \\ \\    /| | | |\\ | ( (`
|_|   |_|__ /_/--\\  |_|  |_|__ |_| \\     \\_\\_/ |_| \\| |_|__      \\_\\/\\/ |_| |_| \\| _)_) "

  #                                        ∩ ___  ∩
  #                                        \/•_ \/
  #                                        | | | |
  #                                      .-|_| |_|
  #                                      \_)\___/
  #                                          \\
  #                                          (__)
  #  ___   _      __    _     ____  ___      _____  _       ___       _       _   _      __
  # | |_) | |    / /\  \ \_/ | |_  | |_)      | |  \ \    // / \     \ \    /| | | |\ | ( (`
  # |_|   |_|__ /_/--\  |_|  |_|__ |_| \      |_|   \_\/\/ \_\_/      \_\/\/ |_| |_| \| _)_)

  @o_winner_art "
                                       ∩ ___  ∩
                                       \\/•_ \\/
                                       | | | |
                                     .-|_| |_|
                                     \\_)\\___/
                                         \\\\
                                         (__)
 ___   _      __    _     ____  ___      _____  _       ___       _       _   _      __
| |_) | |    / /\\  \\ \\_/ | |_  | |_)      | |  \\ \\    // / \\     \\ \\    /| | | |\\ | ( (`
|_|   |_|__ /_/--\\  |_|  |_|__ |_| \\      |_|   \\_\\/\\/ \\_\\_/      \\_\\/\\/ |_| |_| \\| _)_) "

  #    __  __                 ∩ ___  ∩
  #    \•\/•/ ∩  ┳┓┳┓┏┓┓ ┏    \/•_ \/
  #    /\  /_/   ┃┃┣┫┣┫┃┃┃    | | | |
  #   U /  \     ┻┛┛┗┛┗┗┻┛  .-|_| |_|
  #    /_/\_\     _______   \_)\___/
  #    //  \\    |       |      \\
  #  (__)  (__)  |       |     (__)

   @draw_art "
   __  __                 ∩ ___  ∩
   \\•\\/•/ ∩  ┳┓┳┓┏┓┓ ┏    \\/•_ \\/
   /\\  /_/   ┃┃┣┫┣┫┃┃┃    | | | |
  U /  \\     ┻┛┛┗┛┗┗┻┛  .-|_| |_|
   /_/\\_\\     _______   \\_)\\___/
   //  \\\\    |       |      \\\\
 (__)  (__)  |       |     (__)"

  def start(_type, _args) do
    Tictactoe.setup_game()
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def setup_game do
    IO.puts(@title_art)

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
    grid = TableRex.Table.new(convert_map_to_grid(internal_gridmap))
     |> TableRex.Table.put_column_meta(:all, color: &Tictactoe.decide_color/2, padding: 4)
      |> TableRex.Table.put_column_meta(3, padding: 1)
    IO.puts(TableRex.Table.render!(grid, horizontal_style: :all, intersection_symbol: "•"))

    winner = start_turn(grid, internal_gridmap, :"Player One (x)")

    # When the code reaches here, either player one or two has won!
    case winner do
      :- ->
        IO.puts(@draw_art)
      :x ->
        IO.puts(@x_winner_art)
      :o ->
        IO.puts(@o_winner_art)
    end
  end

  def start_turn(grid, internal_gridmap, player, finished \\ false)
  def start_turn(_, _, _, finished) when finished != false, do: finished
  def start_turn(grid, internal_gridmap, player, _) do
    input = IO.gets("#{player} select an empty coordinate (ex: a0, b1, c2, etc...): ") |> String.trim() |> String.to_existing_atom()

    # ERROR CHECKING
    if Map.get(internal_gridmap, input) != :- do
      if !Map.has_key?(internal_gridmap, input) do
        raise ArgumentError
      else
        raise "ERROR! #{input} is not an empty coordinate! Please try again and input a valid coordinate!"
      end
    end

    internal_gridmap = Map.put(internal_gridmap, input, convert_player_to_symbol(player))
    IO.puts(TableRex.Table.render!(update_grid_with_internal_map(grid, internal_gridmap), horizontal_style: :all, intersection_symbol: "•"))

    if player == :"Player One (x)" do
      start_turn(grid, internal_gridmap, :"Player Two (o)", game_is_finished(internal_gridmap))
    else
      start_turn(grid, internal_gridmap, :"Player One (x)", game_is_finished(internal_gridmap))
    end
  rescue
    ArgumentError ->
      IO.puts("ERROR! Please try again and input a valid coordinate!")
      start_turn(grid, internal_gridmap, player)
    error in RuntimeError ->
      IO.puts(error.message)
      start_turn(grid, internal_gridmap, player)
  end

  def game_is_finished(internal_gridmap) do
    if !Enum.any?(internal_gridmap, fn {_, value} -> value == :- end) do
      :-
    else
      check_victory_conditions(internal_gridmap)
    end
  end

  def check_victory_conditions(map) do
    cond do
      (map.a0 == map.a1) && (map.a1 == map.a2) && (map.a0 != :-) -> map.a0
      (map.b0 == map.b1) && (map.b1 == map.b2) && (map.b0 != :-) -> map.b0
      (map.c0 == map.c1) && (map.c1 == map.c2) && (map.c0 != :-) -> map.c0
      (map.a0 == map.b0) && (map.b0 == map.c0) && (map.a0 != :-) -> map.a0
      (map.a1 == map.b1) && (map.b1 == map.c1) && (map.a1 != :-) -> map.a1
      (map.a2 == map.b2) && (map.b2 == map.c2) && (map.a2 != :-) -> map.a2
      (map.a0 == map.b1) && (map.b1 == map.c2) && (map.a0 != :-) -> map.a0
      (map.a2 == map.b1) && (map.b1 == map.c0) && (map.a2 != :-) -> map.a2
      true -> false
    end
  end

  def convert_player_to_symbol(player) do
    if player == :"Player One (x)" do
      :x
    else
      :o
    end
  end

  def update_grid_with_internal_map(grid, internal_gridmap), do: TableRex.Table.clear_rows(grid) |> TableRex.Table.add_rows(convert_map_to_grid(internal_gridmap))

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
end
