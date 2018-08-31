# SPL_CGT_INCLUDE: ../Common/MongoInclude_h.cgt
# SPL_CGT_INCLUDE: ../Common/QueryCommon_h.cgt
# SPL_CGT_INCLUDE: ../Common/MongoInit_h.cgt

package Delete_h;
use strict; use Cwd 'realpath';  use File::Basename;  use lib dirname(__FILE__);  use SPL::Operator::Instance::OperatorInstance; use SPL::Operator::Instance::Annotation; use SPL::Operator::Instance::Context; use SPL::Operator::Instance::Expression; use SPL::Operator::Instance::ExpressionTree; use SPL::Operator::Instance::ExpressionTreeEvaluator; use SPL::Operator::Instance::ExpressionTreeVisitor; use SPL::Operator::Instance::ExpressionTreeCppGenVisitor; use SPL::Operator::Instance::InputAttribute; use SPL::Operator::Instance::InputPort; use SPL::Operator::Instance::OutputAttribute; use SPL::Operator::Instance::OutputPort; use SPL::Operator::Instance::Parameter; use SPL::Operator::Instance::StateVariable; use SPL::Operator::Instance::TupleValue; use SPL::Operator::Instance::Window; 
sub main::generate($$) {
   my ($xml, $signature) = @_;  
   print "// $$signature\n";
   my $model = SPL::Operator::Instance::OperatorInstance->new($$xml);
   unshift @INC, dirname ($model->getContext()->getOperatorDirectory()) . "/../impl/nl/include";
   $SPL::CodeGenHelper::verboseMode = $model->getContext()->isVerboseModeOn();
   print '#include <SPL/Runtime/Function/SPLFunctions.h>', "\n";
   print '#include <SPL/Runtime/Operator/OperatorMetrics.h>', "\n";
   print '#include <streams_boost/shared_ptr.hpp>', "\n";
   print '#include <streams_boost/thread/tss.hpp>', "\n";
   print '#include <streams_boost/typeof/typeof.hpp>', "\n";
   print '#include <streams_boost/foreach.hpp>', "\n";
   print '#define foreach STREAMS_BOOST_FOREACH', "\n";
   print "\n";
   print '#include "Mongo.h"', "\n";
   print "\n";
   print 'using std::string;', "\n";
   print 'using streams_boost::shared_ptr;', "\n";
   print "\n";
   print 'using namespace mongo;', "\n";
   print "\n";
   print 'namespace com { namespace ibm { namespace streamsx { namespace mongodb {', "\n";
   print "\n";
   print 'inline string buildConnUrl(const string& dbHost, uint32_t dbPort) {', "\n";
   print '	string connUrl = dbHost;', "\n";
   print '	connUrl += ":";', "\n";
   print '	connUrl += SPL::spl_cast<SPL::rstring,uint32_t>::cast(dbPort);', "\n";
   print '	return connUrl;', "\n";
   print '}', "\n";
   print "\n";
   print 'inline string buildDbCollection(const string& db, const string& collection) {', "\n";
   print '	string dbCollection(db);', "\n";
   print '	dbCollection += ".";', "\n";
   print '	dbCollection += collection;', "\n";
   print '	return dbCollection;', "\n";
   print '}', "\n";
   print "\n";
   print '}}}}', "\n";
   print "\n";
   print 'using namespace com::ibm::streamsx::mongodb;', "\n";
   print "\n";
   SPL::CodeGen::headerPrologue($model);
   print "\n";
   print "\n";
   	my $sslOptions = ($_ = $model->getParameterByName('sslOptions')) ? $_->getValueAt(0)->getCppExpression() : '';
   	my $sslOptionsType = ($_ = $model->getParameterByName('sslOptions')) ? $_->getValueAt(0)->getCppType() : '';
   	
   	my $clientOptions ="client::Options().setSSLMode( (client::Options::SSLModes)(int)sslOptions.get_sslMode())" .
   										".setSSLCAFile( sslOptions.get_caFile())" .
   										".setSSLPEMKeyFile( sslOptions.get_pemKeyFile())" .
   										".setSSLPEMKeyPassword( sslOptions.get_pemKeyPassword())" .
   										".setSSLCRLFile( sslOptions.get_crlFile())" .
   										".setSSLAllowInvalidCertificates( sslOptions.get_allowInvalidCertificates())" .
   										".setSSLAllowInvalidHostnames( sslOptions.get_allowInvalidHostnames())" if ($sslOptions);
   print "\n";
   print "\n";
   print 'template<class Void>', "\n";
   print 'struct MongoInit {', "\n";
   print '	static Status status_;', "\n";
   print '	', "\n";
   print 'private:', "\n";
   print '	static Status init(';
   print "$sslOptionsType const& sslOptions" if($sslOptionsType);
   print ' ) {', "\n";
   print '		return client::initialize(';
   print $clientOptions;
   print ');', "\n";
   print '	}', "\n";
   print '};', "\n";
   print "\n";
   print 'template<class Void>', "\n";
   print 'Status MongoInit<Void>::status_ = init(';
   print $sslOptions;
   print ');', "\n";
   print "\n";
   print 'class MY_OPERATOR: public MY_BASE_OPERATOR {', "\n";
   print "\n";
   print 'public:', "\n";
   print '	MY_OPERATOR();', "\n";
   print '	virtual ~MY_OPERATOR();', "\n";
   print "\n";
   print '	void allPortsReady();', "\n";
   print '	void prepareToShutdown();', "\n";
   print "\n";
   print '	void process(Tuple const & tuple, uint32_t port);', "\n";
   print "\n";
   print 'private:', "\n";
   print '	Metric & nDeletesMetric_;', "\n";
   print "\n";
   print '	static streams_boost::thread_specific_ptr<DBClientConnection> connPtr_;', "\n";
   print '	DBClientConnection * getDBClientConnection(const string& db, const string& dbHost, uint32_t dbPort);', "\n";
   print "\n";
   my $findFieldsExpr = ($_ = $model->getParameterByName('findFields')) ? $_->getValueAt(0) : undef;
   my $findQueryExpr = ($_ = $model->getParameterByName('findQuery')) ? $_->getValueAt(0) : undef;
   
   if (defined $findFieldsExpr && $findFieldsExpr->hasStreamAttributes()) {
   print "\n";
   print '	BSONObj buildFindFieldsBO(Tuple const & tuple);', "\n";
   }
   else {
   print "\n";
   print '	BSONObj buildFindFieldsBO();', "\n";
   }
   
   
   if (defined $findQueryExpr && $findQueryExpr->hasStreamAttributes()) {
   print "\n";
   print '	BSONObj buildFindQueryBO(Tuple const & tuple);', "\n";
   }
   else {
   print "\n";
   print '	BSONObj buildFindQueryBO();', "\n";
   }
   print "\n";
   print "\n";
   print '	BSONObj findFieldsBO_;', "\n";
   print '	BSONObj findQueryBO_;', "\n";
   print "\n";
   print '};', "\n";
   print "\n";
   SPL::CodeGen::headerEpilogue($model);
   print "\n";
   CORE::exit $SPL::CodeGen::USER_ERROR if ($SPL::CodeGen::sawError);
}
1;
