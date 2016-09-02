require 'game/neural_network'

RSpec.describe 'NeuralNetwork' do
  def assert_eval(network, input)
    output = network.eval input
    expect(output.length).to eq 1
    expect(output.first)
  end

  # This is the example I used while refactoring *shrug*
  it 'passes the xor example they provide in ai4r' do
    trainer = NeuralNetwork::Trainer.init(
      layer_sizes:   [2, 2, 1],
      learning_rate: 0.25,
      momentum:      0.1,
      random:        Random.new(1),
    )

    2001.times do |i|
      trainer = trainer.train([0,0], [0])
      trainer = trainer.train([0,1], [1])
      trainer = trainer.train([1,0], [1])
      trainer = trainer.train([1,1], [0])
    end

    network = trainer.network

    assert_eval(network, [0, 0]).to be < 0.1
    assert_eval(network, [0, 1]).to be > 0.9
    assert_eval(network, [1, 0]).to be > 0.9
    assert_eval(network, [1, 1]).to be < 0.1
  end
end
