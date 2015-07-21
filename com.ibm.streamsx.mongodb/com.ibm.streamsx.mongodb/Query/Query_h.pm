
package Query_h;
use strict; use Cwd 'realpath';  use File::Basename;  use lib dirname(__FILE__);  use SPL::Operator::Instance::OperatorInstance; use SPL::Operator::Instance::Annotation; use SPL::Operator::Instance::Context; use SPL::Operator::Instance::Expression; use SPL::Operator::Instance::ExpressionTree; use SPL::Operator::Instance::ExpressionTreeEvaluator; use SPL::Operator::Instance::ExpressionTreeVisitor; use SPL::Operator::Instance::ExpressionTreeCppGenVisitor; use SPL::Operator::Instance::InputAttribute; use SPL::Operator::Instance::InputPort; use SPL::Operator::Instance::OutputAttribute; use SPL::Operator::Instance::OutputPort; use SPL::Operator::Instance::Parameter; use SPL::Operator::Instance::StateVariable; use SPL::Operator::Instance::TupleValue; use SPL::Operator::Instance::Window; 
sub main::generate($$) {
   my ($xml, $signature) = @_;  
   print "// $$signature\n";
   my $model = SPL::Operator::Instance::OperatorInstance->new($$xml);
   unshift @INC, dirname ($model->getContext()->getOperatorDirectory()) . "/../impl/nl/include";
   $SPL::CodeGenHelper::verboseMode = $model->getContext()->isVerboseModeOn();
   print '#include <SPL/Runtime/Operator/OperatorMetrics.h>', "\n";
   print '#include <streams_boost/thread/tss.hpp>', "\n";
   print '#include <streams_boost/typeof/typeof.hpp>', "\n";
   print '#include <streams_boost/foreach.hpp>', "\n";
   print '#define foreach STREAMS_BOOST_FOREACH', "\n";
   print "\n";
   print '#include "Mongo.h"', "\n";
   print "\n";
   print 'using std::string;', "\n";
   print "\n";
   print 'using namespace mongo;', "\n";
   print "\n";
   SPL::CodeGen::headerPrologue($model);
   print "\n";
   print "\n";
   print 'template<class Void>', "\n";
   print 'struct MongoInit {', "\n";
   print '	static Status status_;', "\n";
   print '};', "\n";
   print "\n";
   print 'template<class Void>', "\n";
   print 'Status MongoInit<Void>::status_ = client::initialize();', "\n";
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
   print '	Metric & nQueriesMetric_;', "\n";
   print "\n";
   print '	static streams_boost::thread_specific_ptr<OPort0Type> otuplePtr_;', "\n";
   print '	OPort0Type * getOutputTuple();', "\n";
   print "\n";
   print '	static streams_boost::thread_specific_ptr<DBClientConnection> connPtr_;', "\n";
   print '	DBClientConnection * getDBClientConnection(const string& dbHost, uint32_t dbPort);', "\n";
   print '	', "\n";
   print '	BSONObj findFieldsBO_;', "\n";
   print '	BSONObj buildFindFieldsBO();', "\n";
   print "\n";
   print '	BSONObj findQueryBO_;', "\n";
   print '	BSONObj buildFindQueryBO();', "\n";
   print '	BSONObj buildFindQueryBO(Tuple const & tuple);', "\n";
   print "\n";
   print '	string buildConnUrl(const string& dbHost, uint32_t dbPort);', "\n";
   print '	string buildDbCollection(const string& db, const string& collection);', "\n";
   print '};', "\n";
   print "\n";
   SPL::CodeGen::headerEpilogue($model);
   print "\n";
   CORE::exit $SPL::CodeGen::USER_ERROR if ($SPL::CodeGen::sawError);
}
1;
