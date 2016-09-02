# Refurbished from https://github.com/SergioFierens/ai4r/blob/409e17b9dc1de9955e23108a09aaef849280dd28/lib/ai4r/neural_network/backpropagation.rb
# This was at the top, I'm probably supposed to include it:
#
#   Author::    Sergio Fierens
#   License::   MPL 1.1
#   Project::   ai4r
#   Url::       http://ai4r.org/
#
#   You can redistribute it and/or modify it under the terms of
#   the Mozilla Public License version 1.1  as published by the
#   Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt


# I don't fully understand it, it was mostly just several hours of mechanical refactoring
# the purpose of which being to let me work with the network independently from the trainer,
# and to interject at various points in the process.
# Most of the changes take the form of introducing immutability (at least from the outside),
# and pushing variable setting / modifying earlier in the callstack.
class NeuralNetwork
  attr_reader :layer_sizes, :synapses

  def initialize(layer_sizes, synapses)
    self.layer_sizes = layer_sizes
    self.synapses    = synapses
  end

  def eval(input_values)
    feedforward(input_values).last
  end

  def neurons_for(input_values)
    neurons = [input_values.dup]
    neurons.concat synapses.map { |w| Array.new w.first.length, 0 }
    neurons[0...-1].each { |layer| layer << 1.0 }
    neurons
  end

  def feedforward(input_values)
    neurons = neurons_for(input_values)
    synapses.each_with_index do |layer_weights, layer|
      layer_sizes[layer+1].times do |tndx|
        sum = neurons[layer].each_index.reduce(0.0) do |sum, fndx|
          sum + (neurons[layer][fndx] * layer_weights[fndx][tndx])
        end
        neurons[layer+1][tndx] = propagation_fn(sum)
      end
    end
    neurons
  end

  # Someone on S.O. recommended this paper for understanding which fn to use
  #   http://yann.lecun.com/exdb/publis/pdf/lecun-98b.pdf
  #   http://stats.stackexchange.com/a/101563
  def propagation_fn(x)   1/(1+Math.exp(-x)) end # alternate: Math.tanh(x)
  def d_propagation_fn(y) y*(1-y)            end # alternate: 1.0 - y**2

  private

  attr_writer :layer_sizes, :synapses
end

class NeuralNetwork
  class Trainer
    def self.init(layer_sizes:, learning_rate:, momentum:, random: Random)
      synapses = random_weights_for(layer_sizes, random)
      network  = NeuralNetwork.new(layer_sizes, synapses)
      changes  = initial_changes(synapses)
      new(network, changes, learning_rate, momentum)
    end

    # synapses indexes: from_layer, from_node_weights, to_node_weight
    def self.random_weights_for(layer_sizes, random)
      layer_sizes.each_cons(2).map do |origin, target|
        Array.new(origin+1) do # 1 for the bias node
          Array.new(target) { ((random.rand 2000)/1000.0) - 1 }
        end
      end
    end

    def self.initial_changes(synapses)
      Array.new(synapses.length) do |w|
        Array.new(synapses[w].length) do |i|
          Array.new(synapses[w][i].length, 0.0)
        end
      end
    end

    attr_reader :network

    def initialize(network, changes, learning_rate, momentum)
      self.network       = network
      self.changes       = changes
      self.learning_rate = learning_rate
      self.momentum      = momentum
    end

    def train(inputs, outputs)
      neurons = network.feedforward(inputs)
      backpropagate(outputs, neurons)
    end

    private

    attr_writer :network
    attr_accessor :changes, :learning_rate, :momentum

    public def backpropagate(expected_output_values, all_neurons)
      all_deltas    = calculate_deltas(all_neurons, expected_output_values)
      synapses      = network.synapses
      next_weights  = []
      next_changes  = []

      (synapses.length-1).downto(0) do |n|
        # values for the current layer
        lweights = synapses[n]
        ldeltas  = all_deltas[n]
        lneurons = all_neurons[n]
        lchanges = changes[n]

        next_changes[n] = []
        next_weights[n] = []

        lweights.each_index do |i|
          layer_weights = lweights[i]
          layer_changes = lchanges[i]
          neuron        = lneurons[i]
          next_changes[n][i] = []
          next_weights[n][i] = []
          layer_weights.each_index do |j|
            change                = ldeltas[j] * neuron
            next_changes[n][i][j] = change
            next_weights[n][i][j] = layer_weights[j] +
                                    learning_rate * change +
                                    momentum      * change
          end
        end
      end

      next_network = NeuralNetwork.new(network.layer_sizes, next_weights)
      Trainer.new(next_network, next_changes, learning_rate, momentum)
    end

    def calculate_deltas(neurons, expecteds)
      all_weights   = network.synapses
      output_deltas = neurons.last.zip(expecteds).map do |actual, expected|
        network.d_propagation_fn(actual) * (expected - actual)
      end

      (neurons.length-2)
        .downto(1)
        .reduce([output_deltas]) { |deltas, layer|
          deltas.unshift(
            neurons[layer].zip(all_weights[layer]).map { |node, synapses|
              derivative = network.d_propagation_fn(node)
              error      = synapses.zip(deltas.first).map { |d, w| d * w }.reduce(0, :+)
              derivative * error
            }
          )
        }
    end
  end
end
