#Get the current working DIR
    if ($psISE) {$BaseDir = Split-Path -Path $psISE.CurrentFile.FullPath    #IF running in ISE, with line by line execution this will work
    } else {$BaseDir = $PSScriptRoot} 

#Cert will be output right nex to this script
    $LocationToSave_PFX = "$BaseDir\Cert.pfx"

    $AuthSubject = "Network Systems Plus, Inc."
    #$AuthSubject = "Test"
#Password to place of PFX
    $PFX_Password = "#T3mpPassword!" | ConvertTo-SecureString -AsPlainText -Force
    $SubjectString="CN=""$($AuthSubject)"""

    $ExistingCerts = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq $SubjectString}

    #Convert Existing Certs to Base64
        #[System.Convert]::ToBase64String(( $ExistingCerts).RawData, ‘InsertLineBreaks’)

#Find Existing Certs
 if ($ExistingCerts) {

      # Confirm if the self-signed Authenticode certificate exists in the computer's Personal certificate store
     Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=""$($AuthSubject)"""}
    # Confirm if the self-signed Authenticode certificate exists in the computer's Root certificate store
     Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Subject -eq "CN=""$($AuthSubject)"""}
    # Confirm if the self-signed Authenticode certificate exists in the computer's Trusted Publishers certificate store
     Get-ChildItem Cert:\LocalMachine\TrustedPublisher | Where-Object {$_.Subject -eq "CN=""$($AuthSubject)"""}


 #Import Certs
} elseif (Test-Path $LocationToSave_PFX) {
   $Authenticode = Import-PfxCertificate -FilePath "$($LocationToSave_PFX)" -Password (ConvertTo-SecureString -String $PFX_Password -Force -AsPlainText ) -CertStoreLocation "Cert:\LocalMachine\My"

   #Cert:\LocalMachine\Root
        #Add the self-signed Authenticode certificate to the computer's root certificate store.
            ## Create an object to represent the LocalMachine\Root certificate store.
             $rootStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("Root","LocalMachine")
            ## Open the root certificate store for reading and writing.
             $rootStore.Open("ReadWrite")
            ## Add the certificate stored in the $authenticode variable.
             $rootStore.Add($Authenticode)
            ## Close the root certificate store.
             $rootStore.Close()
 
        #Cert:\LocalMachine\TrustedPublisher
        # Add the self-signed Authenticode certificate to the computer's trusted publishers certificate store.
            ## Create an object to represent the LocalMachine\TrustedPublisher certificate store.
             $publisherStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("TrustedPublisher","LocalMachine")
            ## Open the TrustedPublisher certificate store for reading and writing.
             $publisherStore.Open("ReadWrite")
            ## Add the certificate stored in the $authenticode variable.
             $publisherStore.Add($authenticode)
            ## Close the TrustedPublisher certificate store.
             $publisherStore.Close()

        #Cert:\LocalMachine\My
        ## Create an object to represent the LocalMachine\TrustedPublisher certificate store.
             $publisherStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("My","LocalMachine")
            ## Open the TrustedPublisher certificate store for reading and writing.
             $publisherStore.Open("ReadWrite")
            ## Add the certificate stored in the $authenticode variable.
             $publisherStore.Add($authenticode)
            ## Close the TrustedPublisher certificate store.
             $publisherStore.Close()

 #Create new Cert
 } else {
        #Generate new SelfSigned Cert
            $Authenticode = New-SelfSignedCertificate -Type Custom -Subject $AuthSubject -KeyUsage DigitalSignature -FriendlyName "NetSysPlus" -CertStoreLocation "Cert:\LocalMachine\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}") -KeyExportPolicy ExportableEncrypted

        #Cert:\LocalMachine\Root
        #Add the self-signed Authenticode certificate to the computer's root certificate store.
            ## Create an object to represent the LocalMachine\Root certificate store.
             $rootStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("Root","LocalMachine")
            ## Open the root certificate store for reading and writing.
             $rootStore.Open("ReadWrite")
            ## Add the certificate stored in the $authenticode variable.
             $rootStore.Add($Authenticode)
            ## Close the root certificate store.
             $rootStore.Close()
 
        #Cert:\LocalMachine\TrustedPublisher
        # Add the self-signed Authenticode certificate to the computer's trusted publishers certificate store.
            ## Create an object to represent the LocalMachine\TrustedPublisher certificate store.
             $publisherStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("TrustedPublisher","LocalMachine")
            ## Open the TrustedPublisher certificate store for reading and writing.
             $publisherStore.Open("ReadWrite")
            ## Add the certificate stored in the $authenticode variable.
             $publisherStore.Add($authenticode)
            ## Close the TrustedPublisher certificate store.
             $publisherStore.Close()

        #Cert:\LocalMachine\My
        ## Create an object to represent the LocalMachine\TrustedPublisher certificate store.
             $publisherStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("My","LocalMachine")
            ## Open the TrustedPublisher certificate store for reading and writing.
             $publisherStore.Open("ReadWrite")
            ## Add the certificate stored in the $authenticode variable.
             $publisherStore.Add($authenticode)
            ## Close the TrustedPublisher certificate store.
             $publisherStore.Close()

        #Export the Cert
            $password = ConvertTo-SecureString -String $PFX_Password -Force -AsPlainText 
            Export-PfxCertificate -cert $Authenticode -FilePath $LocationToSave_PFX -Password $password
    }
#[System.Convert]::ToBase64String(( Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=""$($AuthSubject)"""}).RawData, ‘InsertLineBreaks’)


Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=""$($AuthSubject)"""}