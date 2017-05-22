
(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)


let package_json_tmpl = {|
{
  "name": "${bsb:name}",
  "version": "${bsb:proj-version}",
  "scripts": {
    "clean": "bsb -clean",
    "clean:all": "bsb -clean-world",
    "build": "bsb",
    "build:all": "bsb -make-world",
    "watch": "bsb -w",
  },
  "keywords": [
    "Bucklescript"
  ],
  "license": "MIT",
  "devDependencies": {
    "bs-platform": "${bsb:bs-version}"
  }
}
|}


let bsconfig_json_tmpl = {|
{
  "name": "${bsb:name}",
  "version": "${bsb:proj-version}",
  "sources": [
    "src"
  ],
  "reason" : { "react-jsx" : true},
  "bs-dependencies" : [
      // add your bs-dependencies here 
  ]
}
|}

let vscode_task_json_impl = {|
{
    "version": "0.1.0",
    "command": "${bsb:bsb}",
    "options": {
        "cwd": "${workspaceRoot}"
    },
    "isShellCommand": true,
    "args": [
        "-w"
    ],
    "showOutput": "always",
    "isWatching": true,
    "problemMatcher": {
        "fileLocation": "absolute",
        "owner": "ocaml",
        "watching": {
            "activeOnStart": true,
            "beginsPattern": ">>>> Start compiling",
            "endsPattern": ">>>> Finish compiling"
        },
        "pattern": [
            {
                "regexp": "^File \"(.*)\", line (\\d+)(?:, characters (\\d+)-(\\d+))?:$",
                "file": 1,
                "line": 2,
                "column": 3,
                "endColumn": 4
            },
            {
                "regexp": "^(?:(?:Parse\\s+)?(Warning|[Ee]rror)(?:\\s+\\d+)?:)?\\s+(.*)$",
                "severity": 1,
                "message": 2,
                "loop": true
            }
        ]
    }
}
|}


 let gitignore_template = ""

let replace s env : string = 
  Bsb_regex.global_substitute "\\${bsb:\\([-a-zA-Z0-9]+\\)}" 
    (fun (_s : string) templates -> 
        match templates with 
        | key::_ -> 
        String_hashtbl.find_exn  env key
        | _ -> assert false 
    ) s

let (//) = Filename.concat 

(** TODO: run npm link *)
let init_sample_project name = 
  let env = String_hashtbl.create 0 in 
  List.iter (fun (k,v) -> String_hashtbl.add env k v  ) [
      "name", name;
      "proj-version", "0.1";
      "bs-version", Bs_version.version;
      "bsb" , Filename.current_dir_name // "node_modules" // ".bin" // "bsb"
  ];
  begin 
    Bsb_build_util.mkp ( name // "src");
    Bsb_build_util.mkp ( name // ".vscode");
    Unix.chdir name ;
    Ext_io.write_file (name//".vscode"//"tasks.json") (replace vscode_task_json_impl env);
    Ext_io.write_file (name//"package.json") (replace package_json_tmpl env);
    Ext_io.write_file (name//"bsconfig.json") (replace bsconfig_json_tmpl env);
    Ext_io.write_file (name//"src"// "test.ml") {|let () = Js.log "hello BuckleScript" |};
    print_endline {|Done!|}
    (** create package.json *)
  end
