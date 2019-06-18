defmodule ImageClassifier do
  @moduledoc """
  TODO: write documentation for ImageClassifier.
  """
  @doc """
  TODO: write docs

  ## Examples

  iex> ImageClassifier.hello()
  :world

  """
  def label(image) do
    label(
      image,
      app_file("retrained_graph.pb"),
      app_file("retrained_labels.txt")
    )
  end

  def label(image, graph_path, labels) when is_binary(graph_path) do
    {:ok, graph} = Tensorflex.read_graph(graph_path)
    label(image, graph, labels)
  end

  def label(image, graph, labels_path) when is_binary(labels_path) do
    labels = read_labels(labels_path)
    label(image, graph, labels)
  end

  def label(image, graph, labels) do
    image
    |> classify_image(graph, labels)
    |> find_label(labels)
  end

  defp classify_image(image, graph, labels) do
    {:ok, decoded, properties} = Jaypeg.decode(image)
    in_width = properties[:width]
    in_height = properties[:height]
    channels = properties[:channels]
    height = width = 224

    {:ok, resized} =
      ImgUtils.resize(decoded, in_width, in_height, channels, width, height)

    {:ok, input_tensor} =
      Tensorflex.binary_to_matrix(resized, width, height * channels)
      |> Tensorflex.divide_matrix_by_scalar(255)
      |> Tensorflex.matrix_to_float32_tensor({1, width, height, channels})

    {:ok, output_tensor} =
      Tensorflex.create_matrix(1, 2, [[length(labels), 1]])
      |> Tensorflex.float32_tensor_alloc()

    Tensorflex.run_session(
      graph,
      input_tensor,
      output_tensor,
      "Placeholder",
      "final_result"
    )
  end

  defp find_label(probes, labels) do
    List.flatten(probes)
    |> Enum.zip(labels)
    |> Enum.max()
  end

  defp read_labels(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp app_file(name) do
    Application.app_dir(:image_classifier, ["priv", name])
  end
end
