defmodule Elixir::IEx do
  import Elixir::Formatter, only: [format_catch: 2, format_stacktrace: 1]

  def start do
    IO.puts "Interactive Elixir (#{Code.version}) - press Ctrl+C to exit"
    function = fn { do_loop([], '') }
    Erlang.user_drv.start([:"tty_sl -c -e", {:erlang, :spawn, [function]}])
    Erlang.timer.sleep(:infinity)
  end

  def do_loop(binding, code_cache) do
    prompt = case code_cache do
    match: []
      "iex> "
    match: _
      "...> "
    end

    code = code_cache ++ Erlang.io.get_line(prompt)

    {binding_to_return, code_cache_to_return} = try do
      { result, new_binding } = Erlang.elixir.eval(code, binding)
      IO.puts inspect(result)
      { new_binding, '' }
    catch: :error, { :badsyntax, {_, _, _, []} }
      { binding, code }
    catch: kind, error
      IO.puts :standard_error, "** #{kind} #{format_catch(kind, error)}"
      Enum.each Code.stacktrace, fn(s) { IO.puts :standard_error, "    #{format_stacktrace(s)}" }
      { binding, '' }
    end

    do_loop(binding_to_return, code_cache_to_return)
  end
end