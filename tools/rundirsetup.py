import os
import sys
import argparse
import pathlib
import shutil
import re
import yaml
import warnings

class RunSetup:
    args: argparse.Namespace
    cfg: dict
    templates: list
    uc: dict
    ucname: str
    def __init__(self):
        parser = argparse.ArgumentParser(
            prog='UseCaseSetup',
            description='Setup run directory for use case')
        parser.add_argument('usecase', type=pathlib.Path, default=None,
            help='use case directory')
        parser.add_argument('sysname', type=str, default=None,
            help='system name')
        parser.add_argument('--rundir', type=pathlib.Path, default=None,
            help='run directory')
        self.args = parser.parse_args()
        self.ucname = os.path.splitext(os.path.basename(self.args.usecase))[0]
        if self.args.rundir is None:
            setattr(self.args, 'rundir', os.path.join('run', self.ucname))
        with open(self.args.usecase) as file:
            self.uc = yaml.safe_load(file)
            if self.uc is None:
                warnings.warn("usecase file is empty: "+self.args.usecase,
                              Warning)
                self.uc = {}
        self.cfg = {}
        self.templates = []
        self.__make_rundir()
        self.__common()
        self.__system()
        self.__templates()
    def __make_rundir(self):
        os.makedirs(self.args.rundir, exist_ok=False)
    def __input_item(self, data: tuple):
        if len(data) < 2:
            sys.exit('ERROR - invalid arguments: '+data)
        if data[0] == "symlink":
            os.symlink(data[1], os.path.join(self.args.rundir, data[2]))
        elif data[0] == "copy":
            if os.path.isdir(data[1]):
                if data[1].endswith("/"):
                    for item in os.listdir(data[1]):
                        s = os.path.join(data[1], item)
                        if os.path.isdir(s):
                            shutil.copytree(s, os.path.join(self.args.rundir,
                                            item))
                        else:
                            shutil.copy2(s, self.args.rundir)
                else:
                    if len(data) == 2:
                        shutil.copytree(data[1], os.path.join(self.args.rundir,
                                        os.path.basename(data[1])))
                    elif len(data) == 3:
                        shutil.copytree(data[1], os.path.join(self.args.rundir,
                                        os.path.basename(data[2])))
            elif os.path.isfile(data[1]):
                if len(data) == 2:
                    shutil.copy2(data[1], self.args.rundir)
                elif len(data) == 3:
                    shutil.copy2(data[1], os.path.join(self.args.rundir,
                                 data[2]))
            else:
                sys.exit('ERROR - file not found: '+data[1])
        else:
            warnings.warn("option unknown in use case: "+data[0], Warning)
    def __setup_files(self, data: tuple):
        if isinstance(data[0], str):
            self.__input_item(data)
        elif isinstance(data[0], list):
            for item in data:
                self.__input_item(item)
    def __setup_vars(self, data: tuple):
        if isinstance(data[0], str):
            self.cfg[data[0]] = data[1]
        elif isinstance(data[0], list):
            for item in data:
                self.cfg[item[0]] = item[1]
    def __setup_tplt(self, data: tuple):
        if isinstance(data[0], str):
            if len(data) == 1:
                self.__input_item(["copy", data[0]])
                self.templates.append(os.path.basename(data[0]))
            if len(data) == 2:
                self.__input_item(["copy", data[0], data[1]])
                self.templates.append(os.path.basename(data[1]))
        elif isinstance(data[0], list):
            for item in data:
                if len(item) == 1:
                    self.__input_item(["copy", item[0]])
                    self.templates.append(os.path.basename(item[0]))
                if len(item) == 2:
                    self.__input_item(["copy", item[0], item[1]])
                    self.templates.append(os.path.basename(item[1]))
    def __setup(self, section: dict):
        for key in section:
            if key == "files":
                self.__setup_files(section[key])
            elif key == "vars":
                self.__setup_vars(section[key])
            elif key == "templates":
                self.__setup_tplt(section[key])
            else:
                warnings.warn("option unknown in use case: "+key, Warning)
    def __common(self):
        if "common" in self.uc:
            self.__setup(self.uc["common"])
    def __system(self):
        if "system" in self.uc:
            if self.args.sysname in self.uc["system"]:
                self.__setup(self.uc["system"][self.args.sysname])
        else:
            warnings.warn("system not defined in use case: "+
                          self.args.sysname, Warning)
    def __templates(self):
        for item in self.templates:
            with open(os.path.join(self.args.rundir, item), 'r') as file:
                filedata = file.read()
            relist = re.findall(r'@\[.*\]', filedata)
            for opt in relist:
                if opt[2:-1] in self.cfg:
                    filedata = filedata.replace(opt, str(self.cfg[opt[2:-1]]))
                else:
                    sys.exit('ERROR - var not defined in use case: '+opt[2:-1])
            with open(os.path.join(self.args.rundir, item), 'w') as file:
                file.write(filedata)

def main(argv):
    rs = RunSetup()

if __name__ == "__main__":
    main(sys.argv[1:])
