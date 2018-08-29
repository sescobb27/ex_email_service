defmodule ServiceMailer.Templates do
  require EEx

  @templates_path Path.expand("lib/service_mailer/templates")
  @templates Path.join([@templates_path, "*.html.eex"])
             |> Path.wildcard()
             |> Enum.map(&Path.basename(&1, ".html.eex"))

  def render(filename, args) do
    if Enum.member?(@templates, filename) do
      Path.join([@templates_path, "#{filename}.html.eex"])
      |> EEx.eval_file(args)
    else
      {:error, :enoexist}
    end
  end
end
