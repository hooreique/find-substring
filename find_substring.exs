# TODO: 사용 법 개선
#   <substring> <path> --mode=['both' | 'name' | 'content'] --name-ext=<extname> --content-ext=<extname>
#   <substring> <path> -m ['both' | 'name' | 'content'] -n <extname> -c <extname>
# TODO: 숨긴 파일, 폴더 들어가지 않기
# TODO: . 으로 시작하는 파일, 폴더 들어가지 않기
# TODO: 그 밖에 ignore 할 이름 구성 가능하게 하기 (node_modules 특별법)

defmodule FindSubstring do
  @target_exts MapSet.new([".txt", ".md", ".csv", ".toml", ".yaml", ".json"])

  def run! do
    case System.argv() do
      [path, substring] ->
        traverse!(path, substring)

      _ ->
        raise ArgumentError, message: "Usage: <path> <substring>"
    end
  end

  defp traverse!(path, substring) do
    case File.stat!(path) do
      %File.Stat{type: :regular} ->
        if path
           |> Path.extname()
           |> String.trim_leading(".")
           |> (&Path.basename(path, &1)).()
           |> String.contains?(substring) do
          IO.puts("#{path}")
        end

        if path
           |> Path.extname()
           |> (&MapSet.member?(@target_exts, &1)).() do
          read!(path, substring)
        end

      %File.Stat{type: :directory} ->
        if path
           |> Path.extname()
           |> String.trim_leading(".")
           |> (&Path.basename(path, &1)).()
           |> String.contains?(substring) do
          IO.puts("#{path}/")
        end

        path
        |> File.ls!()
        |> Enum.each(&traverse!(Path.join(path, &1), substring))

      _ ->
        :ok
    end
  end

  defp read!(filename, substring) do
    File.stream!(filename)
    |> Enum.with_index()
    |> Enum.each(fn {line, index} ->
      if String.contains?(line, substring) do
        IO.write("#{filename}:#{index + 1}; #{line}")
      end
    end)
  end
end

FindSubstring.run!()
