from PyQt5.QtWidgets import QApplication, QMainWindow, QFileDialog, QMessageBox, QPushButton, QLabel, QTextEdit
from PyQt5.QtGui import QTextCursor, QTextBlockFormat ,QColor
from PyQt5.QtCore import Qt

import sys
import os
import subprocess

QUAD_POS = (20, 100)
SEM_ERR_POS = (150, 100)
SYNTAX_ERR_POS = (370, 100)
SYMBOL_TABLE_POS = (20, 250)
CODE_POS = (20, 500)

QUAD_SIZE = (100, 100)
SEM_ERR_SIZE = (200, 100)
SYNTAX_ERR_SIZE = (200, 100)
SYMBOL_TABLE_SIZE = (600, 200)
CODE_SIZE = (600, 100)


class Compiler():
    window : QMainWindow = None
    code : str = None
    codePath : str = None
    codeFileName : str = None

    #Content
    quadruplesContent : str = None
    semErrorContent : str = None
    symbolTableContent : str = None
    syntaxErrorContent : str = None

    #Labels
    quadruplesText : QTextEdit = None
    semErrorText : QTextEdit = None
    symbolTableText : QTextEdit = None
    syntaxErrorText : QTextEdit = None
    codeText : QTextEdit = None

    #Formats
    normalFormat = QTextBlockFormat()
    errorFormat = QTextBlockFormat()


    def highlightLine(self, lineNO):
        cursor = self.codeText.textCursor()
        cursor.select(QTextCursor.Document)
        cursor.setBlockFormat(self.normalFormat)

        cursor = QTextCursor(self.codeText.document().findBlockByLineNumber(lineNO - 1))
        cursor.setBlockFormat(self.errorFormat)


    def createTextWidget(self, text, pos, size):
        textWidget = QTextEdit(self.window)
        textWidget.setReadOnly(True)
        textWidget.move(pos[0], pos[1])
        textWidget.resize(size[0], size[1])
        textWidget.setText(text)
        return textWidget
    
    def __init__(self):

        self.normalFormat.setBackground(Qt.white)
        self.errorFormat.setBackground(Qt.red)

        app = QApplication([])
        window = QMainWindow()
        window.resize(700, 700)
        window.setWindowTitle('C Compiler')
        self.window = window
        btn = QPushButton('Open File', window)
        btn.move(20, 20)
        btn.clicked.connect(self.readFileBtn)

        compileBtn = QPushButton('Compile', window)
        compileBtn.move(20, 60)
        compileBtn.clicked.connect(self.compileBtn)

        #Labels
        self.quadruplesText = self.createTextWidget("Quadruples", QUAD_POS, QUAD_SIZE)

        self.semErrorText = self.createTextWidget("Semantic Error", SEM_ERR_POS, SEM_ERR_SIZE)

        self.symbolTableText = self.createTextWidget("Symbol Table", SYMBOL_TABLE_POS, SYMBOL_TABLE_SIZE)

        self.syntaxErrorText = self.createTextWidget("Syntax Error", SYNTAX_ERR_POS, SYNTAX_ERR_SIZE)

        self.codeText = self.createTextWidget("Code", CODE_POS, CODE_SIZE)

        window.show()

        sys.exit(app.exec_())
        

    def readFileBtn(self):
        currentPath = os.getcwd()  # Get the current working directory

        filename, _ = QFileDialog.getOpenFileName(self.window, 'Open File', currentPath, 'Text Files (*.txt)')
        if filename:
            relativePath = os.path.relpath(filename, currentPath)  # Get the relative path
            file = open(filename, 'r')
            self.code = file.read()
            file.close()
            self.codePath = relativePath
            self.codeFileName = os.path.basename(filename)


    def compileBtn(self):
        if self.code:
            #Reset labels text
            self.quadruplesText.setText("Quadruples")
            self.semErrorText.setText("Semantic Error")
            self.symbolTableText.setText("Symbol Table")
            self.syntaxErrorText.setText("Syntax Error")


            p = subprocess.Popen(["program.exe"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
            command = f"{self.codeFileName}\n"
            p.stdin.write(command.encode('utf-8'))
            p.stdin.flush()
            output = p.stdout.read()        
            
            quadruples = open("quadruple.txt", "r")
            self.quadruplesContent = quadruples.read()
            quadruples.close()

            semError = open("semantic-error.txt", "r")
            self.semErrorContent = semError.read()
            semError.close()

            symbolTable = open("symbol-tables.txt", "r")
            self.symbolTableContent = symbolTable.read()
            symbolTable.close()

            syntaxError = open("syntax-error.txt", "r")
            self.syntaxErrorContent = syntaxError.read()
            syntaxError.close()

            self.codeText.setText("Code\n" + self.code)
            self.quadruplesText.setText("Quadruples\n" + self.quadruplesContent)
            self.semErrorText.setText("Semantic Error\n" + self.semErrorContent)
            self.symbolTableText.setText("Symbol Table\n" + self.symbolTableContent)
            self.syntaxErrorText.setText("Syntax Error\n" + self.syntaxErrorContent)
            

            if self.semErrorContent.find("Line Number") != -1 or self.syntaxErrorContent.find("Line Number") != -1:
                lineNo = -1
                if self.semErrorContent.find("Line Number")!= -1:
                    startIndex = self.semErrorContent.find("Line Number")
                    startIndex += len("Line Number") + 1
                    lineNo = int(self.semErrorContent[startIndex:startIndex + 1])
                    

                elif self.syntaxErrorContent.find("Line Number")!= -1:
                    startIndex = self.syntaxErrorContent.find("Line Number")
                    startIndex += len("Line Number") + 1
                    lineNo = int(self.syntaxErrorContent[startIndex:startIndex + 1])
                    


                self.highlightLine(lineNo + 1)

        else:
            QMessageBox.warning(self.window, 'Error', 'No file selected', QMessageBox.Ok)




if __name__ == '__main__':
    compiler = Compiler()
    

    