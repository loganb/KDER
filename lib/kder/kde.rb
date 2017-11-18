require 'matrix'

class Kder
  require_relative 'bandwidth'
  require_relative '../util/statistics'

  Sigmas = 2.5 
  MeshCount = 2e3
  MinimumThresholdValue = 1e-2
  MinimumStepSize = 1e-3
  DifferenceThreshold = 1e-3
  class << self
    ## 
    # :singleton-method: kde
    # Accepts a single member array plus optional additional information
    # Returns a two member array, [x_vals,y_vals] representing the kde
    def kde(arr, bw = nil, opts = {}.freeze)
      opts = {sigmas: Sigmas, sampling_density: MeshCount, threshold: MinimumThresholdValue, minimum_delta: DifferenceThreshold}.merge(opts)
      unless bw # is nil
        bw = Bandwidth.silverman(arr)
      end
      bw = bw == 0 ? 0.1 : bw
      # Initialization steps
      range = bw*opts[:sigmas]
      min = arr.min - range
      max = arr.max + range
      step_size = (max-min)/(opts[:sampling_density].to_f)
      step_size = step_size < MinimumStepSize ? MinimumStepSize : step_size
      arr.sort!
      # initialize the range variables
      ranges = (min..max).step(step_size).to_a
      output = [[min,0]]
      old_intensity = 0
      # Step through the range
      ranges[1..-1].map.with_index do |mid, i|
        high_end = mid + range
        lower_end = mid - range
        selection_range = (lower_end..high_end)
        included = arr.select {|a| selection_range.include?(a)}
        intensity = included.map {|a| Kder::Statistics.custom_pdf(a-mid, bw) }.inject(:+) || 0
        unless intensity < opts[:threshold] or (intensity - old_intensity).abs < opts[:minimum_delta]
          output << [mid, intensity ] 
          old_intensity = intensity
        end
      end
      output << [max,0]
      output.compact.transpose
    end

    #
    # :singleton-method: kdevec
    # Works just like kdevec, but arr is a list of 2-D points of sample value and magnitude. Is this valid math? ¯\_(ツ)_/¯
    # 
    def kdevec(arr, bw = nil, opts = {}.freeze)
      opts = {sigmas: Sigmas, sampling_density: MeshCount, threshold: MinimumThresholdValue, minimum_delta: DifferenceThreshold}.merge(opts)
      raise "bandwidth must be specified for now" unless bw

      values = arr.sort_by { |v| v[0] }

      # Initialization steps
      range = bw*opts[:sigmas]
      min = values.first[0] - range
      max = values.last[0]  + range
      step_size = (max-min)/(opts[:sampling_density].to_f)
      step_size = step_size < MinimumStepSize ? MinimumStepSize : step_size

      # initialize the range variables
      ranges = (min..max).step(step_size).to_a
      output = [[min,0]]
      old_intensity = 0
      # Step through the range
      ranges[1..-1].map.with_index do |mid, i|
        high_end  = mid + range
        lower_end = mid - range
        selection_range = (lower_end..high_end)
        included = values.select {|v| selection_range.include?(v[0])}
        intensity = included.map {|v| v[1] * Kder::Statistics.custom_pdf(v[0]-mid, bw) }.inject(:+) || 0
        unless intensity < opts[:threshold] or (intensity - old_intensity).abs < opts[:minimum_delta]
          output << [mid, intensity ] 
          old_intensity = intensity
        end
      end
      output << [max,0]
      output.compact.transpose      
    end

    #
    # Smooths multiple data sets with a shared x-axis at the same time. 
    #
    # values in the form of: 
    #
    # [ 
    #   [x1, y1, z1, k1],
    #   [x2, y2, 0, z3], # "Hole" where there is no data for z
    #   ...
    # ]
    #
    #
    def kdemultivec(values, bw, opts = {}.freeze)
      opts = {sigmas: Sigmas, sampling_density: MeshCount, threshold: MinimumThresholdValue, minimum_delta: DifferenceThreshold}.merge(opts)

      # Initialization steps
      range = bw*opts[:sigmas]
      min = values.first[0] - range
      max = values.last[0]  + range
      step_size = (max-min)/(opts[:sampling_density].to_f)
      step_size = step_size < MinimumStepSize ? MinimumStepSize : step_size

      # initialize the range variables
      ranges = (min..max).step(step_size).to_a
      output = [Array.new(values.first.length-1, 0).unshift(min)]
      old_intensities = Vector::elements(Array.new(values.first.length-1, 0))
      # Step through the range
      ranges[1..-1].map do |mid|
        high_end  = mid + range
        lower_end = mid - range
        selection_range = (lower_end..high_end)
        included = values.select {|v| selection_range.include?(v[0])}

        intensities = included.collect { |vec| Vector::elements(vec[1..-1],false) * Kder::Statistics.custom_pdf(vec[0] - mid, bw) }.
          inject(&:+) || old_intensities 

        unless intensities.all? { |v| v < opts[:threshold] } or (intensities - old_intensities).all? { |v| v.abs < opts[:minimum_delta] }
          output << intensities.to_a.unshift(mid) 
          old_intensities = intensities
        end
      end
      output << Array.new(values.first.length - 1, 0).unshift(max)
      output.compact.transpose
    end
  end
end
