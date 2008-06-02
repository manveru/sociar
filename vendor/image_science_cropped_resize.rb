class ImageScience
  def cropped_resize(w,h)
    r1 = w.to_f/h.to_f
    r2 = width.to_f/height.to_f
    r3 = r1/r2
    l, r, t, b = 0, width, 0, height

    if r1<r2
      l += (width - r3*width.to_f)/2
      r += -l
    else
      t += (width - width.to_f/r3)/2
      b += -t
    end

    with_crop(l.to_i, t.to_i, r.to_i, b.to_i) do |img|
      img.resize(w.to_i,h.to_i) do |thumb|
        yield thumb
      end
    end
  end
end
