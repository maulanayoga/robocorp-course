*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.Tables
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.PDF
Library    Screenshot
Library    RPA.Archive

*** Variables ***
${DownloadURL}    https://robotsparebinindustries.com/orders.csv
${CSVPath}    D:/wok/Berca/Robocorp/robocorp-part2/Input/orders.csv
${OutputPath}    D:/wok/Berca/Robocorp/robocorp-part2/Output
${counter}    ${0}    
*** Tasks ***
Orders robots from RobotSpareBin Industries Inc
    Download CSV    ${DownloadURL}    ${CSVPath}
    ${Orders}=    Get Orders
    Open Browser & close modal
    FOR    ${Order}    IN    @{Orders}
        Sleep    1
        Click Button    OK
        Log    ${Order}
        Log    ${Order['Head']}
        Fill form    ${Order}
        Wait Until Keyword Succeeds    5x    1s    Preview form
        Wait Until Keyword Succeeds    5x    1s    Submit Form
        Screenshot robot
        Create pdf receipt
        Add preview to pdf
        Order robot
        # ${counter}    Evaluate    ${counter}+1
    END
    Create Zip
    

# Saves the order HTML receipt as a PDF file
    

*** Keywords ***
Download CSV
    [Arguments]    ${url}    ${csv}
    Download    ${url}    ${csv}    overwrite=True 

Get Orders
    ${OrdersTB}=    Read table from CSV    ${CSVPath}    header=True
    RETURN    ${OrdersTB}

Open Browser & close modal
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Maximize Browser Window

Fill form
    [Arguments]    ${Order}
    ${OrderNumber}    Convert To String    ${Order['Order number']}
    ${OrderHead}    Convert To String    ${Order['Head']}
    ${OrderBody}    Convert To String    ${Order['Body']}
    ${OrderLegs}    Convert To String    ${Order['Legs']}
    ${OrderAddress}    Convert To String    ${Order['Address']}

    Set Global Variable    ${OrderNumber}


    Sleep    1
    Select From List By Value    id:head    ${OrderHead}
    Select Radio Button    body    ${OrderBody}
    Input Text    css:input.form-control    ${OrderLegs}
    Input Text    id:address    ${OrderAddress}

    Execute JavaScript    window.scrollBy(0, 800) 

Preview form
    Wait Until Element Is Visible    id:preview
    Click Button    id:preview
    
Submit form
    # Set Local Variable    ${receipt}    //*[@id="receipt"]
    Wait Until Element Is Visible    id:order 
    Click Element    id:order
    Page Should Contain Element    //*[@id="receipt"]

Screenshot robot
    #Screenshot    id:receipt    ${OutputPath}/screenshot/${OrderNumber}_receipt.
    Wait Until Element Is Visible    id:robot-preview-image
    Sleep    1s
    Screenshot    id:robot-preview-image    ${OutputPath}/screenshot/${OrderNumber}_preview.png

Create pdf receipt
    Wait Until Element Is Visible    id:receipt
    ${orderhtml}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${orderhtml}    ${OutputPath}/pdf/${OrderNumber}_receipt.pdf

Add preview to pdf
    # Open Pdf    ${OutputPath}/pdf/${OrderNumber}_receipt.pdf
    Sleep    1s
    ${Preview}=    Create List    ${OutputPath}/screenshot/${OrderNumber}_preview.png
    Add Files To Pdf    ${Preview}    ${OutputPath}/pdf/${OrderNumber}_receipt.pdf    append=True
    # Close Pdf    ${OutputPath}/pdf/${OrderNumber}_receipt.pdf
Order robot
    Sleep    1s
    Wait Until Element Is Visible    id:order-another
    Click Button    id:order-another    

Create Zip
    Archive Folder With Zip    ${OutputPath}/pdf     ${OutputPath}/archive.zip
    



