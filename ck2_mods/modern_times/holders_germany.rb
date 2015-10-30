ModernTimesDatabase::HOLDERS_GERMANY = {
  d_brunswick: {
    congress_of_vienna: {use: "e_britannia George 3"},
    "1820.1.29" => {use: "e_britannia George 4"},
    "1830.6.26" => {use: "e_britannia William 2"},
    "1837.6.20" => {name: "Ernest Augustus | Windsor", lived: "1771.6.5 - 1851.11.18", father: "e_britannia George 3"},
    "1851.11.18" => {name: "George | Windsor", lived: "1819.5.27 - 1878.6.12", father: "Ernest Augustus 1"},
    "1866.9.20" => nil,
  },
  k_pomerania: {
    # There's one previous Frederick William here
    "1786.8.17" => {
      name: "Frederick William | Hohenzollern",
      lived: "1744.9.25 - 1797.11.16",
    },
    "1797.11.16" => {
      name: "Frederick William | Hohenzollern",
      lived: "1770.7.3 - 1840.6.7",
      father: "Frederick William 1",
    },
    "1840.6.7" => {
      name: "Frederick William | Hohenzollern",
      lived: "1795.10.15 - 1861.1.2",
      father: "Frederick William 2",
    },
    "1861.1.2" => {
      name: "Wilhelm | Hohenzollern",
      lived: "1797.3.22 - 1888.3.9",
      father: "Frederick William 2",
    },
    "1871.1.18" => nil,
    # Reboot as East Germany
    end_ww2: {
      name: "Wilhelm | Pieck",
      lived: "1876–1960",
    },
    "1950.7.25" => {
      name: "Walter | Ulbricht",
      lived: "1893–1973",
    },
    "1971.5.3" => {
      name: "Erich | Honecker",
      lived: "1912–1994",
    },
    "1989.10.18" => {
      name: "Egon | Krenz",
      lived: "1937-",
    },
    german_reunification: nil,
  },
  c_weimar: {
    "1758.5.28" => {
      name: "Charles Augustus | Saxe-Weimar-Eisenach",
      lived: "1757.9.3 – 1828.6.14"
    },
    "1828.6.14" => {
      name: "Charles Frederick | Saxe-Weimar-Eisenach",
      lived: "1783.2.2 – 1853.7.8",
    },
    "1853.7.8" => {
      name: "Charles Alexander | Saxe-Weimar-Eisenach",
      lived: "1818.6.24 – 1901.1.5",
    },
    german_unification: nil,
  },
  d_mecklemburg: {
    "1692.6.21" => {
      name: "Frederick William | Mecklenburg-Schwerin",
      lived: "1675.3.28 - 1713.7.31",
    },
    "1713.7.31" => {
      name: "Karl Leopold | Mecklenburg-Schwerin",
      lived: "1678.11.26 - 1747.11.28",
    },
    "1728.1.1" => { # Amazingly whole internet doesn't know better than year date :-/
      name: "Christian Ludwig | Mecklenburg-Schwerin",
      lived: "1683.11.15 - 1756.5.30",
    },
    "1756.5.30" => {
      name: "Frederick | Mecklenburg-Schwerin",
      lived: "1717.11.9 - 1785.4.24",
      father: "Christian Ludwig 1",
    },
    "1785.4.24" => {
      name: "Frederick Francis | Mecklenburg-Schwerin",
      lived: "1756.12.10 - 1837.2.1",
    },
    "1837.2.1" => {
      name: "Paul Frederick | Mecklenburg-Schwerin",
      lived: "1800.9.15 - 1842.3.7",
    },
    "1842.3.7" => {
      name: "Frederick Francis | Mecklenburg-Schwerin",
      lived: "1823.2.28 - 1883.4.15",
      father: "Paul Frederick 1",
    },
    german_unification: nil,
  },
  e_germany: {
    "1871.1.18" => { use: "k_pomerania Wilhelm 1" },
    "1888.3.9" => {
      name: "Friedrich | Hohenzollern",
      lived: "1831.10.18 - 1888.6.15",
      father: "k_pomerania Wilhelm 1",
      religion: :protestant,
    },
    "1888.6.15" => {
      lived: "1859.1.27 - 1941.6.4",
      name: "Wilhelm | Hohenzollern",
      father: "Friedrich 1",
      religion: :protestant,
    },
    # Backdate, ignore interregnum
    "1918.11.28" => {
      name: "Friedrich | Ebert",
      lived: "1871.2.4 – 1925.2.28",
      religion: :catholic,
    },
    # Ignore temporary ones, backdating
    "1925.2.28" => {
      name: "Paul | von Hindenburg", lived: "1847.10.2 - 1934.8.2",
      religion: :protestant,
    },
    "1934.8.2" => {
      name: "Adolf | Hitler", lived: "1889.4.20 - 1945.4.30",
      religion: :catholic,
      health: 7,
      traits: ["ambitious", "wroth"],
      events: {
        crowning: PropertyList[
          "effect", PropertyList["set_character_flag", "horde_invader"],
          "prestige", 1000, # enough to start 2 wars
        ],
      },
    },
    "1945.4.30" => {
      name: "Karl | Doenitz", lived: "- 1980.12.24",
      religion: :protestant,
    },
    end_ww2: nil,
    german_reunification: { use: "k_germany Helmut 2" },
    "1998.10.27" => {
      name: "Gerhard | Schroeder",
      lived: "1944.4.7 -",
      religion: :protestant,
    },
    "2005.11.22" => {
      name: "Angela | Merkel",
      lived: "1954.7.17 -",
      female: true,
      religion: :protestant,
    },
  },
  k_germany: {
    # Now this is bullshit on so many levels...
    # German "presidents" do nothing, so choosing chancellor as much more prominent person
    # Backdating a lot
    end_ww2: {
      name: "Konrad | Adenauer",
      lived: "1876.1.5 – 1967.4.19",
      religion: :catholic,
    },
    "1963.10.17" => {
      name: "Ludwig | Erhard",
      lived: "1897.2.4 – 1977.5.5",
      religion: :protestant,
    },
    "1966.12.1" => {
      name: "Kurt Georg | Kiesinger",
      lived: "1904.4.6 – 1988.3.9",
      religion: :catholic,
    },
    "1969.10.22" => {
      name: "Willy | Brandt",
      lived: "1913.12.18 – 1992.10.8",
      religion: :protestant,
    },
    "1974.5.16" => { # 1
      name: "Helmut | Schmidt",
      lived: "1918.12.23 -",
      religion: :protestant,
    },
    "1982.10.1" => { # 2
      name: "Helmut | Kohl",
      lived: "1930.4.3 -",
      religion: :catholic,
    },
    german_reunification: nil,
  },
  d_bavaria: {
    "1679.5.26" => {
      name: "Maximilian Emanuel | Wittelsbach",
      lived: "1662.7.11 – 1726.2.26",
    },
    "1726.2.26" => {
      name: "Charles Albert | Wittelsbach",
      lived: "1697.8.6 – 1745.1.20",
    },
    "1745.1.20" => {
      name: "Maximilian Joseph | Wittelsbach",
      lived: "1727.3.28 – 1777.12.30",
    },
    "1777.12.30" => {
      name: "Charles Theodore | Wittelsbach",
      lived: "1724.12.11 – 1799.2.16",
    },
    "1799.2.16" => {
      name: "Maximilian | Wittelsbach",
      lived: "1756.5.27 – 1825.10.13",
    },
    "1825.10.13" => {
      name: "Ludwig | Wittelsbach",
      lived: "1786.8.25 – 1868.2.29",
    },
    "1848.3.20" => {
      name: "Maximilian | Wittelsbach",
      lived: "1811.11.28 – 1864.3.10",
    },
    "1864.3.10" => {
      name: "Ludwig | Wittelsbach",
      lived: "1845.8.25 – 1886.6.13",
    },
    german_unification: nil,
    # They continued as German vassals until end of WW1
  },
  d_saxony: {
    "1763.12.17" => {
      name: "Frederick Augustus | Wettin",
      lived: "1750.12.23 - 1827.5.5",
    },
    "1827.5.5" => {
      name: "Anthon | Wettin",
      lived: "1755.12.27 - 1836.6.6",
    },
    "1836.6.6" => {
      name: "Frederick Augustus | Wettin",
      lived: "1797.5.18 - 1854.8.9",
    },
    "1854.8.9" => {
      name: "John | Wettin",
      lived: "1801.12.12 - 1873.10.29",
    },
    german_unification: nil,
    # They continued as German vassals until end of WW1
  },
  # There was actually Hesse-Kassel and Hesse-Darmstandt
  d_franconia: {
    "1813.10.30" => {
      name: "William | Hesse",
      lived: "1743.6.3 - 1821.2.27",
    },
    "1821.2.27" => {
      name: "William | Hesse",
      lived: "1777.7.28 - 1847.11.20",
    },
    "1847.11.20" => {
      name: "Frederick William | Hesse",
      lived: "1802.8.20 - 1875.1.6",
    },
    prussia_annexes_hannover: nil,
  },
  k_bavaria: {
    # Backfill
    "1918.11.11" => {name: "Karl | Seitz", lived: "1869.9.4 – 1950.2.3"},
    "1920.12.9"  => {name: "Michael | Hainisch", lived: "1858.8.15 – 1940.2.26"},
    "1928.12.10" => {name: "Wilhelm | Miklas", lived: "1872.10.15 – 1956.3.20"},
    anschluss: nil,
    end_ww2: {name: "Karl | Renner", lived: "- 1950.12.31"},
    # Backfill, predecessor died in office
    "1950.12.31" => {name: "Theodor | Körner", lived: "- 1957.1.4"},
    # Backfill, predecessor died in office
    "1957.1.4" => {name: "Adolf | Schärf", lived: "- 1965.2.28"},
    # Backfill, predecessor died in office
    "1965.2.28" => {name: "Franz | Jonas", lived: "1899.10.4 – 1974.4.24"},
    # Backfill, predecessor died in office
    "1974.4.24" => {name: "Rudolf | Kirchschläger", lived: "1915.3.20 – 2000.3.30"},
    "1986.7.8" => {name: "Kurt | Waldheim", lived: "1918.12.21 – 2007.6.14"},
    "1992.7.8" => {name: "Thomas | Klestil", lived: "1932.11.4 – 2004.7.6"},
    # Backfill, predecessor died in office, why the fuck do they keep electing barely alive presidents?
    "2004.7.6" => {name: "Heinz | Fischer", lived: "1938.10.9 -"},
  },
  # Württemberg
  d_swabia: {
    # as duke, elector, then king
    "1797.12.23" => {
      name: "Frederick | Württemberg",
      lived: "1754.11.6 – 1816.10.30",
    },
    "1816.10.30" => {
      name: "William | Württemberg",
      lived: "1781.9.27 – 1864.6.25",
      father: "Frederick 1",
    },
    "1864.6.25" => {
      name: "Charles | Württemberg",
      lived: "6 March 1823 in Stuttgart – 1891.10.6",
      father: "William 1",
    },
    # still in charge, just under empire of Germany
    "1871.1.18" => nil,
  },
}
