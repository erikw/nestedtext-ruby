* `#dump*`
  * `inline_level` and `sort_keys` like https://nestedtext.org/en/stable/nestedtext.dumps.html
* `#load*`
  * `on_dup` like https://nestedtext.org/en/stable/nestedtext.loads.html
* serialize Symbol as custom class? 
   * Current
      * strict=true: Symbol => Error
      * strict=false: Symbol => String
   * New
      * strict=true: Symbol => Error
      * strict=false: Symbol => String
      * strict=false, encsymbol=true: Symbol => CustomClass
   * EncSymbol will not work as a key in a hash though, just like any Custom Class.
