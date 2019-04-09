defmodule MozartFetcher.DecoderTest do
  use ExUnit.Case

  alias MozartFetcher.{Decoder, Config, Envelope}

  doctest Decoder

  describe "#data_to_struct" do
    test "when the JSON is successfully decoded it is transformed into a struct" do
      json = ~s({"head":[],"bodyInline":"<DIV id=\\"site-container\\">","bodyLast":[]})

      expected = {:ok, %Envelope{
        head: [],
        bodyInline: ~s(<DIV id="site-container">),
        bodyLast: []
      }}

      assert Decoder.data_to_struct(json, %Envelope{}) == expected
    end
  end

  describe "#list_to_struct_list" do
    test "when the list of JSON is successfuly decoded it is transformed into a list of structs" do
      json =  ~s({ "components\": [{"id": "stream-icons", "endpoint": "localhost:8082/success", "must_succeed": true },
                                  {"id": "stream-icons", "endpoint": "localhost:8082/success", "must_succeed": true }
               ]})

      expected = {
        :ok, [
          %MozartFetcher.Config{endpoint: "localhost:8082/success", id: "stream-icons", must_succeed: true},
          %MozartFetcher.Config{endpoint: "localhost:8082/success", id: "stream-icons", must_succeed: true}
        ]
       }

      assert Decoder.list_to_struct_list(json, %Config{}) == expected
    end
  end

  describe "when the map keys do not match the struct" do
    test "it returns an error" do
      json = ~s( "components": [{:"Foo": "Bar" }])
      assert Decoder.data_to_struct(json, %Config{}) == {:error}
    end
  end
end