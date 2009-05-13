package backupconverter;


import java.io.File;
import java.io.IOException;
import java.util.Properties;

import org.exist.EXistException;
import org.exist.backup.BackupDescriptor;
import org.exist.backup.BackupDirectory;
import org.exist.storage.ConsistencyCheckTask;
import org.exist.storage.DBBroker;
import org.exist.storage.SystemTask;
import org.exist.util.Configuration;

/**
 * Schedulable System Task for eXisr which
 * will backup the database and create an
 * Akoma Ntoso Layout mirroring the database
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class ANMirrorTask implements SystemTask
{
    private String existBackupLocation = null;
    private BackupDirectory existBackupDir = null;
    private boolean incremental = false;
    private File anDestination = null;
    private boolean anDestinationOverwrite = false;

    private ConsistencyCheckTask consistencyCheckTask = null;

    public final static String EXIST_BACKUP_LOCATION_PROP_NAME = "eXist.backup.location";
    public final static String INCREMENTAL_PROP_NAME = "incremental";
    public final static String AN_DESTINATION_PROP_NAME = "an.destination";
    public final static String AN_DESTINATION_OVERWRITE_PROP_NAME = "an.destination.overwrite";

    @Override
    public void configure(Configuration config, Properties properties) throws EXistException
    {
        existBackupLocation = properties.getProperty(EXIST_BACKUP_LOCATION_PROP_NAME, "/tmp");
        existBackupDir = new BackupDirectory(existBackupLocation);
        String incr = properties.getProperty(INCREMENTAL_PROP_NAME, "false").toUpperCase();
        incremental = (incr.equals("TRUE") || incr.equals("YES"));
        anDestination = new File(properties.getProperty(AN_DESTINATION_PROP_NAME, "/tmp/an"));
        String overwr = properties.getProperty(AN_DESTINATION_OVERWRITE_PROP_NAME, "false").toUpperCase();

        anDestinationOverwrite = (overwr.equals("TRUE") || overwr.equals("YES"));


        //setup the consistencyCheckTask
        Properties consistencyCheckTaskProperties = new Properties();
        consistencyCheckTaskProperties.put(ConsistencyCheckTask.OUTPUT_PROP_NAME, existBackupLocation);
        consistencyCheckTaskProperties.put(ConsistencyCheckTask.BACKUP_PROP_NAME, "yes");
        consistencyCheckTaskProperties.put(ConsistencyCheckTask.INCREMENTAL_PROP_NAME, incremental ? "yes" : "no");
        this.consistencyCheckTask = new ConsistencyCheckTask();
        
    }

    @Override
    public void execute(DBBroker broker) throws EXistException
    {
        //run the consistency checker first to generate the backup
        consistencyCheckTask.execute(broker);

        try
        {

            //get the backup details
            BackupDescriptor lastBackupDesc = existBackupDir.lastBackupFile();
            Properties lastBackupProps = lastBackupDesc.getProperties();

            //was it an incremental backup
            if(lastBackupProps.getProperty(BackupDescriptor.INCREMENTAL_PROP_NAME, "no").toUpperCase().equals("YES"))
            {
                //yes

                //TODO handle incremental updates to the mirror
            }
            else
            {
                //no

                if(anDestination.exists())
                {
                    if(anDestinationOverwrite)
                    {
                        //remove the existing mirror, and recreate mirror root
                        anDestination.delete();
                        anDestination.mkdir();
                    }
                    else
                    {
                        throw new EXistException("Aknoma Ntoso mirror destination: '" + anDestination.getAbsolutePath() + "' already exists");
                    }
                }
                    

                BackupConverter backupConverter = new BackupConverter();
                backupConverter.convert(new File(existBackupLocation, lastBackupDesc.getName()), anDestination);
            }
        }
        catch(IOException ioe)
        {
            throw new EXistException(ioe.getMessage(), ioe);
        }
    }
}
