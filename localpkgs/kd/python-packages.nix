# Generated by pip2nix 0.8.0.dev1
# See https://github.com/nix-community/pip2nix

{ pkgs, fetchurl, fetchgit, fetchhg }:

self: super: {
  "attrs" = super.buildPythonPackage rec {
    pname = "attrs";
    version = "23.1.0";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/attrs/attrs-23.1.0-py3-none-any.whl";
      sha256 = "012x6glahfkg28ncs726dcnbm76gib3j1861d8jv8byw5i9b8a0z";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "cachetools" = super.buildPythonPackage rec {
    pname = "cachetools";
    version = "5.3.1";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/cachetools/cachetools-5.3.1-py3-none-any.whl";
      sha256 = "1415235xqp2ywmp8g7krjshc7ak3ckrkfr7h6qpbl57ax8g67vwm";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "certifi" = super.buildPythonPackage rec {
    pname = "certifi";
    version = "2023.7.22";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/certifi/certifi-2023.7.22-py3-none-any.whl";
      sha256 = "1ffvkq408hzmycg7m4y5zrc81nvpicp4gbpnp0384zc575sh7mlj";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "chardet" = super.buildPythonPackage rec {
    pname = "chardet";
    version = "4.0.0";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/chardet/chardet-4.0.0-py2.py3-none-any.whl";
      sha256 = "198xs99vbvcj312d1bk7bgn7aix5h64sqi3hwvr1i4gxcr6har7q";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "click" = super.buildPythonPackage rec {
    pname = "click";
    version = "8.1.7";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/click/click-8.1.7-py3-none-any.whl";
      sha256 = "0a0c77rq458xjfkrkdxqinlza5447kby9w8msshpf0haqabgnx5f";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "decorator" = super.buildPythonPackage rec {
    pname = "decorator";
    version = "4.4.2";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/decorator/decorator-4.4.2-py2.py3-none-any.whl";
      sha256 = "0q7p11gj5g158gb1igy9cna5ppxf03zkrm2gpr4acjycl3159yj1";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "google-auth" = super.buildPythonPackage rec {
    pname = "google-auth";
    version = "2.23.0";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/google-auth/google_auth-2.23.0-py2.py3-none-any.whl";
      sha256 = "19zp9jn6ylpss09z81awpdlgjzc3pcr8wqq2p3shgqnigd043v1c";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."cachetools"
      self."pyasn1-modules"
      self."rsa"
      self."urllib3"
    ];
  };
  "idna" = super.buildPythonPackage rec {
    pname = "idna";
    version = "2.10";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/idna/idna-2.10-py2.py3-none-any.whl";
      sha256 = "1h280sli58v5dapmf79rnnqdrrk0xjn8vi3pxppknllv3r5q0zdr";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "jsondiff" = super.buildPythonPackage rec {
    pname = "jsondiff";
    version = "1.2.0";
    src = ./../../Library/Caches/pip/wheels/9c/7a/3d/7532032fb72ad8ab31cbe5c6c648bd5343f66e54edb28b5954/jsondiff-1.2.0-py3-none-any.whl;
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "jsonnet" = super.buildPythonPackage rec {
    pname = "jsonnet";
    version = "0.18.0";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/jsonnet/jsonnet-0.18.0.tar.gz";
      sha256 = "1m1mqa71gwlsisg66mx2aasbhnm573v7i3ykssvvd5whgr117kac";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "jsonschema" = super.buildPythonPackage rec {
    pname = "jsonschema";
    version = "4.19.0";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/jsonschema/jsonschema-4.19.0-py3-none-any.whl";
      sha256 = "1jrj3sscrzpwgr71iylri6mck4cw580xc8241v90kzs571mc4g84";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."attrs"
      self."jsonschema-specifications"
      self."referencing"
      self."rpds-py"
    ];
  };
  "jsonschema-specifications" = super.buildPythonPackage rec {
    pname = "jsonschema-specifications";
    version = "2023.7.1";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/jsonschema-specifications/jsonschema_specifications-2023.7.1-py3-none-any.whl";
      sha256 = "1c940pajzrnyfgi0485qy8iz58qgw0xn3a908808m0jrnr0g7b85";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."referencing"
    ];
  };
  "kensho-deploy" = super.buildPythonPackage rec {
    pname = "kensho-deploy";
    version = "1.18.6";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/kensho-deploy/kensho_deploy-1.18.6-py3-none-any.whl";
      sha256 = "1h3xpvswppvrv3n90flrpnwkd2fy6j36f665dx3rc7pv22n93c0q";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."click"
      self."jsondiff"
      self."jsonnet"
      self."jsonschema"
      self."kubernetes"
      self."lark-parser"
      self."networkx"
      self."pyjwt"
      self."pyyaml"
      self."requests"
      self."rjsonnet"
      self."urllib3"
    ];
  };
  "kubernetes" = super.buildPythonPackage rec {
    pname = "kubernetes";
    version = "22.6.0";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/kubernetes/kubernetes-22.6.0-py2.py3-none-any.whl";
      sha256 = "083y8i4lq48wq9g302y5nxxc9sp3vjf36qmvywr3wcqfnklrwcjx";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."certifi"
      self."google-auth"
      self."python-dateutil"
      self."pyyaml"
      self."requests"
      self."requests-oauthlib"
      self."setuptools"
      self."six"
      self."urllib3"
      self."websocket-client"
    ];
  };
  "lark-parser" = super.buildPythonPackage rec {
    pname = "lark-parser";
    version = "0.12.0";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/lark-parser/lark_parser-0.12.0-py2.py3-none-any.whl";
      sha256 = "0xf6fd1lk2n71186rhislvaj2yzr3pkdd9vk9m0gx1x7bg5k1bqf";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "networkx" = super.buildPythonPackage rec {
    pname = "networkx";
    version = "2.5.1";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/networkx/networkx-2.5.1-py3-none-any.whl";
      sha256 = "01jf1jgq3kfqfd61912hx0m8kpsjnj086cn2fk2z92g9sy78ad86";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."decorator"
    ];
  };
  "oauthlib" = super.buildPythonPackage rec {
    pname = "oauthlib";
    version = "3.2.2";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/oauthlib/oauthlib-3.2.2-py3-none-any.whl";
      sha256 = "1jpvcxq0xr3z50fdg828in1icgz8cfcy3sc04r85vqhkmjdg4fc1";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "pyasn1" = super.buildPythonPackage rec {
    pname = "pyasn1";
    version = "0.5.0";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/pyasn1/pyasn1-0.5.0-py2.py3-none-any.whl";
      sha256 = "0mqss25alxjzl76blcs383k7xy8gd03ivbxwr9c97b51888158l7";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "pyasn1-modules" = super.buildPythonPackage rec {
    pname = "pyasn1-modules";
    version = "0.3.0";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/pyasn1-modules/pyasn1_modules-0.3.0-py2.py3-none-any.whl";
      sha256 = "0b8n9ac70q1kywc3hc699drx0i5xxy8bs25y2v3zp7qd8znxdk6k";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."pyasn1"
    ];
  };
  "pyjwt" = super.buildPythonPackage rec {
    pname = "pyjwt";
    version = "2.8.0";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/pyjwt/PyJWT-2.8.0-py3-none-any.whl";
      sha256 = "0823w2rjmh7xf16m7xmg2x794aglj6d1d4iipfjjsk645hwpq4jr";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "python-dateutil" = super.buildPythonPackage rec {
    pname = "python-dateutil";
    version = "2.8.2";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/python-dateutil/python_dateutil-2.8.2-py2.py3-none-any.whl";
      sha256 = "1aaxjfp4lrz8c6qls3vdhw554lan3khy9afyvdcvrssk6kf067cn";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."six"
    ];
  };
  "pyyaml" = super.buildPythonPackage rec {
    pname = "pyyaml";
    version = "6.0.1";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/pyyaml/PyYAML-6.0.1.tar.gz";
      sha256 = "0hsa7g6ddynifrwdgadqcx80khhblfy94slzpbr7birn2w5ldpxz";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "referencing" = super.buildPythonPackage rec {
    pname = "referencing";
    version = "0.30.2";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/referencing/referencing-0.30.2-py3-none-any.whl";
      sha256 = "1pvvvp451zlsrq9p3ik4i7afhwfl8nr11r7rlyb9w6hjnrlnd6s4";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."attrs"
      self."rpds-py"
    ];
  };
  "requests" = super.buildPythonPackage rec {
    pname = "requests";
    version = "2.25.1";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/requests/requests-2.25.1-py2.py3-none-any.whl";
      sha256 = "07l7fm7y9zkvmpfli803dni6iwyyhy1f804y46wycam46r70h462";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."certifi"
      self."chardet"
      self."idna"
      self."urllib3"
    ];
  };
  "requests-oauthlib" = super.buildPythonPackage rec {
    pname = "requests-oauthlib";
    version = "1.3.1";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/requests-oauthlib/requests_oauthlib-1.3.1-py2.py3-none-any.whl";
      sha256 = "1dfspmj87kr7nc1d22aqy7z0dhs7dq6hk7f00jihb3gvl80waxr5";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."oauthlib"
      self."requests"
    ];
  };
  "rjsonnet" = super.buildPythonPackage rec {
    pname = "rjsonnet";
    version = "0.5.3";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/rjsonnet/rjsonnet-0.5.3.tar.gz";
      sha256 = "1xz5cp2jl4062a0dcjhn960q37dsl6z52mfpkglzn6sg0scp9nxc";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "rpds-py" = super.buildPythonPackage rec {
    pname = "rpds-py";
    version = "0.10.3";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/rpds-py/rpds_py-0.10.3.tar.gz";
      sha256 = "1jyizwbppdarfmshq1vaqqifq2nq2pnnsz4gb2k28ghsasvyphgw";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "rsa" = super.buildPythonPackage rec {
    pname = "rsa";
    version = "4.9";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/rsa/rsa-4.9-py3-none-any.whl";
      sha256 = "1xvlc59ipksbkz746bkxibnpwwm8bzvhwk9lcxlph575b280s9lh";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      self."pyasn1"
    ];
  };
  "six" = super.buildPythonPackage rec {
    pname = "six";
    version = "1.16.0";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/six/six-1.16.0-py2.py3-none-any.whl";
      sha256 = "0m02dsi8lvrjf4bi20ab6lm7rr6krz7pg6lzk3xjs2l9hqfjzfwa";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "urllib3" = super.buildPythonPackage rec {
    pname = "urllib3";
    version = "1.26.5";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/urllib3/urllib3-1.26.5-py2.py3-none-any.whl";
      sha256 = "0z2siwabara1prpr8vbqhmcx11m6jh1y9kr6v2cqyr96vxs06fkm";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  "websocket-client" = super.buildPythonPackage rec {
    pname = "websocket-client";
    version = "1.6.3";
    src = fetchurl {
      url = "https://pypi.beta-p.kensho.com/api/package/websocket-client/websocket_client-1.6.3-py3-none-any.whl";
      sha256 = "00xdsbnxkdivmj28j3rks2xvx3scq7ffyim2bwxbgazba7831z3c";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [ ];
    checkInputs = [ ];
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
}
