defmodule ImageClassifier do
  @moduledoc """
  Image classification using Tensorflow.
  """

  @doc """
  Returns the most probable label along with an accuracy for a given image.

  ## Examples

  iex> ImageClassifier.label(File.read!("file/t54wjgedk1kd3d8s.jpg"))
  {0.49980872869491577, "tvs"}

  """
  def label(image) do
    label(
      image,
      app_file("retrained_graph.pb"),
      app_file("retrained_labels.txt")
    )
  end

  @doc """
  Returns the most probable label along with an accuracy for a given image.

  ## Example

  iex(1)> image = File.read!("tv.jpeg")
  <<255, 216, 255, 224, 0, 16, 74, 70, 73, 70, 0, ...>>>
  iex(2)> {:ok, graph} = Tensorflex.read_graph("retrained_graph.pb")
  {:ok,
   %Tensorflex.Graph{
     def: #Reference<0.1322660680.104464391.77632>,
     name: "retrained_graph.pb"
   }}
  iex(3)> labels = ImageClassifier.read_labels("retrained_labels.txt")
  ["headphones", "hi fi audio speakers", "tools", "tv audio accessories", "tvs"]
  iex(4)> ImageClassifier.label(image, graph, labels)
  {0.9993681311607361, "tvs"}
  """
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

  @doc """
  Read all labels separated by a new line from a given file.

  ## Examples

  iex> ImageClassifier.read_labels("dir/retrained_labels.txt")
  ["headphones", "hi fi audio speakers", "tools", "tv audio accessories", "tvs"]

  """
  def read_labels(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def classify_image(image, graph, labels) do
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

  defp app_file(name) do
    Application.app_dir(:image_classifier, ["priv", name])
  end
end
